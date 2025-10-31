# Arquitetura do Backend CodeRats

Este documento descreve a arquitetura do backend, seus principais componentes, fluxos (autenticação, autorização e features), convenções de código, persistência, configuração e diretrizes para evoluir a documentação via OpenAPI/Swagger.

## Visão Geral

- Stack: Spring Boot 3.4 (Java 21), Spring Web, Spring Security, Spring Data JPA, Bean Validation, Flyway, PostgreSQL, JJWT, SpringDoc OpenAPI.
- Build/Run: Maven (multi-stage Docker). `pom.xml` define dependências e plugins.
- Estilo de pacotes: package-by-feature com pastas de infraestrutura (security, config, github) e camadas (domain, repository, service, web/dto) quando faz sentido.
- Migrations: Flyway (`classpath:db/migration`).
- OpenAPI/Swagger: Springdoc configurado e exposto em `/swagger-ui`.

## Organização do Projeto

- Aplicação principal: `coderats/Codigo/apps/backend/src/main/java/dev/coderats/backend/CodeRatsBackendApplication.java`
- Camadas e infraestrutura:
  - `security/` – filtro JWT e configuração HTTP Security
  - `config/` – serviços de infraestrutura (ex.: JWT)
  - `github/` – integração OAuth com GitHub
  - `domain/` – entidades JPA
  - `repository/` – repositórios Spring Data
  - `service/` – regras de negócio
  - `web/` e `web/dto/` – controladores REST e DTOs
  - `features/<feature>/` – pacotes por funcionalidade (ex.: `group`, `checkin`)

## Dependências Principais (Maven)

- Spring Web, Security, Data JPA, Validation
- PostgreSQL + Flyway (inclui `flyway-database-postgresql`)
- JJWT (`io.jsonwebtoken`) para assinar/validar JWT
- SpringDoc OpenAPI UI para Swagger

Arquivo: `coderats/Codigo/apps/backend/pom.xml`

## Configuração e Ambientes

- Propriedades: `coderats/Codigo/apps/backend/src/main/resources/application.properties`
  - Porta: `server.port=${SERVER_PORT:8080}`
  - DataSource: `spring.datasource.*` com variáveis `DB_URL`, `DB_USER`, `DB_PASS`
  - JPA: `ddl-auto=validate`, `open-in-view=false`, SQL formatado
  - Flyway: habilitado, `baseline-on-migrate=true`, `clean-disabled=true`
  - JWT: `security.jwt.secret`, `security.jwt.expiration-ms`
  - GitHub OAuth: `github.oauth.client-id`, `github.oauth.client-secret`, `github.oauth.redirect-uri`
  - SpringDoc: `springdoc.swagger-ui.path=/swagger-ui`
- Import `.env`: `spring.config.import=optional:file:.env[.properties]` (na raiz do projeto, mesmo nível do `docker-compose.yml`).
- Perfis: `SPRING_PROFILES_ACTIVE=dev` (ver `application-dev.properties`).
- Docker Compose: `coderats/Codigo/docker-compose.yml` sobe `db`, `pgadmin`, `backend`, `mobile`.

## Persistência e Migrations

- BD: PostgreSQL 16.
- Migrations: `coderats/Codigo/apps/backend/src/main/resources/db/migration/V1__init.sql` define tabelas:
  - `users`, `groups`, `checkins`, `comments`, `likes`, `badges`, `group_participants`, `user_badges` + índices e gatilhos de `updated_at`.
- Entidades mapeadas no código neste momento:
  - `User` (tabela `users`): `coderats/Codigo/apps/backend/src/main/java/dev/coderats/backend/domain/User.java`
  - `Group` e `GroupParticipant` (tabelas `groups` e `group_participants`): `features/group`
  - `Checkin` (tabela `checkins`): `features/checkin`
- Convenções:
  - Soft delete por coluna `deleted_at` (implementado em `Group` e `Checkin`, planejável nas demais entidades).
  - Auditoria simples com `created_at`/`updated_at` via `@PrePersist/@PreUpdate` e triggers SQL.

## Segurança (JWT)

- Filtro de autenticação: `JwtAuthFilter` extrai `Authorization: Bearer <token>` e, quando válido, coloca um `UsernamePasswordAuthenticationToken` no contexto com o `subject` (UUID do usuário).
  - Arquivo: `coderats/Codigo/apps/backend/src/main/java/dev/coderats/backend/security/JwtAuthFilter.java:30`
  - Rotas ignoradas (sem exigência de token): `/auth/**`, `/v3/api-docs/**`, `/swagger-ui/**`, `OPTIONS` – ver `shouldNotFilter(...)`: `coderats/Codigo/apps/backend/src/main/java/dev/coderats/backend/security/JwtAuthFilter.java:30`
- Serviço JWT: geração e validação de tokens HMAC-SHA512.
  - Gera token com `subject = userId` e claim `github_user` – `coderats/Codigo/apps/backend/src/main/java/dev/coderats/backend/config/JwtService.java:35`
  - Faz parse/validação do token – `coderats/Codigo/apps/backend/src/main/java/dev/coderats/backend/config/JwtService.java:32`
- Configuração HTTP Security: stateless, CSRF desabilitado, CORS habilitado, `JwtAuthFilter` antes de `UsernamePasswordAuthenticationFilter`.
  - Arquivo: `coderats/Codigo/apps/backend/src/main/java/dev/coderats/backend/security/SecurityConfig.java:35`
  - Observação: neste momento há `permitAll()` global; os controladores que exigem login validam manualmente o usuário no `SecurityContext`. Recomenda-se evoluir para restrições por rota e/ou `@PreAuthorize`.

## Autenticação (OAuth GitHub → JWT)

Fluxo resumido:
1. App cliente recebe `code` do GitHub OAuth.
2. POST para `/auth/github/callback` com `{ "code": "..." }`.
3. Backend troca o `code` por `access_token` no GitHub; busca perfil do usuário.
4. Cria/atualiza `User` local e retorna `{ user, token }` com JWT assinado.

Componentes:
- Controller: `coderats/Codigo/apps/backend/src/main/java/dev/coderats/backend/web/AuthController.java:10` e `:15`
- Service: `coderats/Codigo/apps/backend/src/main/java/dev/coderats/backend/service/AuthService.java`
- Integração GitHub: `coderats/Codigo/apps/backend/src/main/java/dev/coderats/backend/github/GitHubOAuthService.java`

Contrato atual:
- Request: `web/dto/AuthGithubCallbackRequest` (campo `code`).
- Response: `web/dto/AuthResponse` com `PrivateUserResponse` e `token`.

Variáveis de ambiente obrigatórias para OAuth:
- `GITHUB_OAUTH_CLIENT_ID`, `GITHUB_OAUTH_CLIENT_SECRET`, `GITHUB_OAUTH_REDIRECT_URI`.

## Autorização

- Identidade do usuário: extraída do `subject` do JWT (UUID) e acessada via `SecurityContextHolder.getContext().getAuthentication().getPrincipal()`.
- Regras de acesso específicas são aplicadas na camada de serviço (ex.: apenas administradores podem atualizar/excluir grupos, via `GroupParticipant.role`).
- Recomendações de endurecimento:
  - Usar `@PreAuthorize("isAuthenticated()")` em controladores/métodos que exigem login.
  - Restringir padrões de rota no `SecurityConfig` (ex.: `requestMatchers("/auth/**", "/swagger-ui/**", "/v3/api-docs/**").permitAll().anyRequest().authenticated()`).

## Features Atuais

### Test
- Endpoints simples de saúde/eco:
  - GET `/test/ping`
  - POST `/test/echo`
- Controller: `coderats/Codigo/apps/backend/src/main/java/dev/coderats/backend/features/test/TestController.java`

### Groups
- Endpoints:
  - GET `/users/me/groups` – lista grupos do usuário autenticado
  - POST `/groups` – cria grupo (autor vira admin)
  - GET `/groups/{groupId}` – detalhes do grupo (inclui participantes)
  - PATCH `/groups/{groupId}` – atualiza (apenas admin)
  - DELETE `/groups/{groupId}` – soft delete (apenas admin)
- Controller: `coderats/Codigo/apps/backend/src/main/java/dev/coderats/backend/features/group/GroupController.java:22` `:30` `:38` `:55` `:76`
- Service: `features/group/GroupService.java`
- Repositórios: `GroupRepository`, `GroupParticipantRepository`
- DTOs: `GroupCreateRequest`, `GroupUpdateRequest`, `GroupWithDetailsResponse`, `UserSummary`

### Checkins
- Modelagem pronta (`Checkin`, `CheckinRepository`, `CheckinCreateRequest`, `CheckinResponse`), porém `CheckinService` e `CheckinController` ainda não implementados.
- Repositório já traz feeds com paginação via SQL nativo.

## Convenções e Padrões

- Camada Web (Controllers): retorna `ResponseEntity<...>`, valida autenticação quando necessário.
- Camada Service: regras de negócio, transações (`@Transactional`) e validações de autorização.
- Camada Repository: Spring Data JPA com queries nativas quando oportuno.
- DTOs públicos para requests/responses; registros Java (`record`) onde se aplica.
- Erros/Exceções: atualmente uso de `RuntimeException` e tratamento ad hoc em controllers. Recomenda-se centralizar com `@ControllerAdvice` e `ProblemDetail` (Spring 6).

## OpenAPI/Swagger

- Já habilitado por `springdoc-openapi-starter-webmvc-ui`. Acesse:
  - UI: `GET /swagger-ui`
  - Docs JSON: `GET /v3/api-docs`
- Boas práticas para melhorar a documentação:
  - Anotar controllers/métodos com `@Tag`, `@Operation`, `@ApiResponses` e `@Parameter`.
  - Anotar DTOs com `@Schema` (ex.: descrições e exemplos).
  - Padronizar códigos de resposta e mensagens de erro (ex.: `ProblemDetail`).

Exemplo de anotação em um endpoint:

```java
@Tag(name = "Groups", description = "Gerenciamento de grupos")
@RestController
class GroupController {
  @Operation(summary = "Lista grupos do usuário autenticado")
  @GetMapping("/users/me/groups")
  public ResponseEntity<List<Group>> listMyGroups() { ... }
}
```

## Como Adicionar uma Nova Feature

1. Schema: criar migration Flyway para novas tabelas/colunas em `db/migration`.
2. Domain: mapear entidades JPA (`domain/` ou `features/<feature>`).
3. Repository: interfaces Spring Data JPA.
4. Service: regras de negócio e transações.
5. Web: controller + DTOs (requests/responses).
6. Segurança: decidir se a rota exige autenticação/roles; ajustar `SecurityConfig` e/ou `@PreAuthorize`.
7. OpenAPI: anotar controller/DTOs para Swagger.
8. Testes: unitários e/ou de integração conforme necessário.

Checklist de exemplo (Comments):
- Migration `V2__comments.sql` (se necessário)
- `features/comment/Comment.java`, `CommentRepository.java`
- `CommentService.java`
- `CommentController.java` com `@Tag` e `@Operation`
- DTOs `CommentCreateRequest`, `CommentResponse`

## Execução Local

- Docker Compose (recomendado): ver `coderats/Codigo/README_DOCKER.md` e `coderats/Codigo/docker-compose.yml`.
- Variáveis mínimas no `.env` (exemplo):

```env
SPRING_PROFILES_ACTIVE=dev
APP_PORT=8080
POSTGRES_DB=coderats_db
POSTGRES_USER=coderats_user
POSTGRES_PASSWORD=coderats_pass
SECURITY_JWT_SECRET=uma_chave_secreta_aleatoria_com_>=64_chars
GITHUB_OAUTH_CLIENT_ID=...
GITHUB_OAUTH_CLIENT_SECRET=...
GITHUB_OAUTH_REDIRECT_URI=http://localhost:8081/auth/callback
```

## Pontos de Atenção e Próximos Passos

- Segurança:
  - Apertar regras de autorização no `SecurityConfig` e/ou usar `@PreAuthorize`.
  - Padronizar erros com `@ControllerAdvice`/`ProblemDetail`.
- Checkins:
  - Implementar `CheckinService`/`CheckinController` e integrar no `GroupWithDetailsResponse`.
- Documentação:
  - Adicionar anotações OpenAPI em controllers/DTOs.
  - Opcional: `@OpenAPIDefinition` com metadados globais (título, descrição, contato).

