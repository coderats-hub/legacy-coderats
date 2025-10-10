# Code Rats API — Backend (Spring Boot, DDD-lite)

Bem-vindo(a)! 🎉 Este README explica **a arquitetura**, **como rodar**, **como contribuir** e **onde estudar** os conceitos usados. A ideia é um **DDD-lite em camadas** simples de manter:

```
Controller/API → Application/Use Cases → Domain → Infrastructure
```

Cada **feature** (ex.: auth, users, groups, checkins, badges) vive no seu **próprio pacote** (package-by-feature). O domínio é **puro Java** (sem Spring/JPA). A infraestrutura (JPA, JWT, etc.) implementa **adapters** para as **ports** definidas na camada de aplicação.

---

## ✨ Visão geral

* **Stack**: Java 21, Spring Boot, Spring Web, Spring Data JPA, Spring Security (JWT), Flyway, PostgreSQL.
* **Estilo**: DDD-lite + Camadas, package-by-feature, monólito modular (fácil de evoluir).
* **API**: definida por **OpenAPI 3.0** (arquivo `openapi.yaml`).

---

## 🗂 Estrutura de pastas (package-by-feature)

```
src/
 └─ main/
    ├─ java/com/coderats/
    │  ├─ shared/
    │  │  ├─ api/           # Ex: ErrorHandler, paginação, DTOs base
    │  │  ├─ domain/        # Tipos utilitários (Identifier, DomainEvent, Clock)
    │  │  └─ infra/         # Config Jackson, Validation, etc.
    │  ├─ auth/
    │  │  ├─ api/           # AuthController, DTOs
    │  │  ├─ app/           # RegisterUseCase, LoginUseCase, ports (TokenProvider)
    │  │  ├─ domain/        # PasswordPolicy, Credentials (puro Java)
    │  │  └─ infra/         # JwtTokenProvider, PasswordEncoder, filtros
    │  ├─ users/
    │  │  ├─ api/           # MeController, UsersController
    │  │  ├─ app/           # GetMe, UpdateMe, ListMyGroups, ports (UserRepository)
    │  │  ├─ domain/        # User, Profile, Value Objects
    │  │  └─ infra/         # UserEntity, UserJpa, mappers
    │  ├─ groups/
    │  │  ├─ api/           # GroupsController
    │  │  ├─ app/           # CreateGroup, GetGroupDetails, UpdateGroup, DeleteGroup
    │  │  ├─ domain/        # Group, Membership, GroupPolicy
    │  │  └─ infra/         # GroupEntity, MembershipEntity, repos
    │  ├─ checkins/
    │  │  ├─ api/           # FeedController, CheckinsController
    │  │  ├─ app/           # GetFeed, CreateCheckin, Like/Unlike, Comments, ports
    │  │  ├─ domain/        # Checkin, Like, Comment, regras
    │  │  └─ infra/         # Entities, repos, mappers
    │  └─ badges/
    │     ├─ api/           # BadgesController
    │     ├─ app/           # ListAllBadges, ListMyBadges
    │     ├─ domain/        # Badge, BadgeService
    │     └─ infra/         # Entities, repos
    └─ resources/
       ├─ application.yaml   # configs Spring
       ├─ db/migration/      # Flyway (V001__init.sql, ...)
       └─ openapi.yaml       # contrato OpenAPI
```

> **Regra de dependência**: `api → app → domain`; `infra` **implementa** as ports do `app`. O **domain não depende** de Spring ou JPA.

---

## 🧭 Mapeamento OpenAPI → Casos de uso

| Endpoint                               | Caso de Uso                        | Observações                                |
| -------------------------------------- | ---------------------------------- | ------------------------------------------ |
| `POST /auth/register`                  | `RegisterUseCase`                  | Cria usuário, retorna perfil privado + JWT |
| `POST /auth/login`                     | `LoginUseCase`                     | Autentica, retorna perfil privado + JWT    |
| `GET /users/me`                        | `GetMe`                            | Requer Bearer JWT                          |
| `PATCH /users/me`                      | `UpdateMe`                         | Atualiza nome/imagem/github_user           |
| `GET /users/me/groups`                 | `ListMyGroups`                     | Paginado (`limit`, `offset`)               |
| `GET /users/me/badges`                 | `ListMyBadges`                     | Badges do usuário                          |
| `GET /users/{id}`                      | `GetPublicProfileWithCommonGroups` | Perfil público + grupos em comum           |
| `GET /feed`                            | `GetFeed`                          | Feed paginado dos grupos que participo     |
| `POST /groups`                         | `CreateGroup`                      | Dono = usuário autenticado                 |
| `GET /groups/{id}`                     | `GetGroupDetails`                  | Participantes + check-ins recentes         |
| `PATCH /groups/{id}`                   | `UpdateGroup`                      | Atualiza e remove participantes (admin)    |
| `DELETE /groups/{id}`                  | `DeleteGroup`                      | Admin; 204                                 |
| `POST /groups/{id}/checkins`           | `CreateCheckin`                    | Só membro do grupo                         |
| `POST/DELETE /checkins/{id}/like`      | `LikeCheckin` / `UnlikeCheckin`    | 409 se já curtiu                           |
| `GET /checkins/{id}/likes`             | `ListLikes`                        | Paginado                                   |
| `POST /checkins/{cid}/comments`        | `AddComment`                       | 201                                        |
| `DELETE /checkins/{cid}/comments/{id}` | `DeleteComment`                    | Autor/admin; 204                           |
| `GET /badges`                          | `ListAllBadges`                    | Catálogo público                           |

---

## 📄 Contrato da API (OpenAPI)

* Arquivo: `Codigo/apps/docs/apidocs.ymal`
* Recomendações:

  * Importar no **Swagger UI/Insomnia/Postman** para testar.
  * Mantemos **DTOs** alinhados ao contrato.

---

## 🧱 Padrões e Convenções

### Camadas

* **Controller/API**: valida DTO com Bean Validation, chama **um** caso de uso.
* **Application/Use Case**: orquestra transação (`@Transactional`), aplica **políticas**, fala com **ports** (repositórios, TokenProvider, etc.).
* **Domain**: **regras de negócio**, entidades e value objects. **Sem Spring/JPA**.
* **Infrastructure**: JPA, JWT, mappers **domain ↔ entity**, adapters que implementam **ports**.

### Erros

* `@ControllerAdvice` centraliza respostas do tipo:

  ```json
  { "statusCode": 400, "message": "Erro de Validação", "details": "..." }
  ```
* Mapeamos:

  * 400 (Domain/Validation)
  * 401 (JWT inválido)
  * 403 (sem permissão, ex.: não é admin)
  * 404 (não encontrado)
  * 409 (conflito: like duplicado)

### Paginação

* Query params `limit` e `offset` → convertidos para `PageRequest/Slice`.
* Respostas retornam arrays e, quando necessário, metadados simples (total opcional).

### Estilo de código

* Java 21 (records quando fizer sentido para DTOs).
* Mappers simples (estáticos) no início; **pode migrar para MapStruct** depois.
* Nomes em inglês no código (consistente) e payloads conforme o OpenAPI.

---

## 🔁 Fluxos de exemplo (end-to-end)

### Criar grupo

1. `POST /groups` (Controller) → `CreateGroup.exec(userId, cmd)`
2. `GroupPolicy` valida regras (datas, método).
3. `GroupRepository.save` (adapter JPA)
4. Retorna `201` com `Group` criado.

### Like em check-in

1. `POST /checkins/{id}/like` → `LikeCheckin.exec(userId, checkinId)`
2. Repositório verifica se já existe like (UNIQUE `checkin_id + author_id`).
3. Se já existir → `409 Conflict`. Senão, cria like e retorna `201`.

---

## 👩‍💻 Como contribuir

1. **Crie branch**: `feature/<escopo>` ou `fix/<escopo>`

   * Exemplos: `feature/auth-register`, `fix/checkins-like-409`
2. **Commits** (Conventional Commits opcional):

   * `feat: criar endpoint de login`
   * `fix: corrigir 409 de like duplicado`
3. **Pull Request**:

   * Descreva o caso de uso, endpoints, decisões de domínio, migrações Flyway.
   * Inclua testes quando possível.

---

## 🛣️ Roadmap de evolução

* [ ] MapStruct para mappers (performance e menos boilerplate)
* [ ] Outbox + eventos de domínio (para futuros serviços assíncronos)
* [ ] Cache (feed, badges) e métricas com Actuator/Prometheus
* [ ] Segurança granular (roles por grupo; admin/owner/member)
* [ ] Modo “read model” para consultas ricas (ex.: feed com joins otimizados)

---

## 📚 Materiais de referência (recomendados para o time)

* **DDD (leve e prático)**

  * *Implementing Domain-Driven Design* — Vaughn Vernon (cap. Aggregates)
  * *Domain-Driven Design Quickly* (resumo grátis da InfoQ)
* **Arquitetura em camadas / Hexagonal**

  * *Ports & Adapters (Hexagonal Architecture)* — Alistair Cockburn (artigo)
  * *Clean Architecture* — Robert C. Martin (cap. boundaries)
* **Spring**

  * Spring Boot Reference (docs oficiais)
  * *Testing with Spring Boot* (guia oficial)
  * *Spring Data JPA — Reference*
* **JWT**

  * *RFC 7519 — JSON Web Token*
  * Documentação da lib JJWT/Nimbus
* **OpenAPI/Swagger**

  * *OpenAPI Specification 3.0* (docs)
  * Swagger Editor / Swagger UI (para inspecionar `openapi.yaml`)
* **Migrations**

  * Flyway Docs (conceitos de versionamento de schema)

> Dica: comece pelos **capítulos de Aggregates** (Vernon) e o artigo de **Ports & Adapters**. Eles “clicam” com o que estamos fazendo aqui.

---

## ❓FAQ rápido

**Por que “DDD-lite”?**
Porque mantemos o que dá mais retorno (limpeza do domínio, casos de uso explícitos, boundaries claros) **sem** sobrecarregar com patterns avançados (event sourcing, CQRS completo, etc.).

**Por que “package-by-feature” e não “package-by-layer”?**
Porque você encontra tudo de uma feature em um só lugar (API, app, domain, infra). Facilita manutenção e onboard.

**Domain sem anotações?**
Sim. Entidades e regras ficam independentes do framework. Testa rápido, troca infra sem dor.

---

## ✅ Checklist para abrir uma nova feature

* [ ] Endpoint definido no `openapi.yaml`
* [ ] DTOs de request/response criados
* [ ] Caso de uso na camada **Application** (+ portas)
* [ ] Regras no **Domain** (com teste unitário)
* [ ] Adapter JPA na **Infra** (+ mapeamento)
* [ ] Controller chamando **um** caso de uso
* [ ] Erros mapeados (400/401/403/404/409)
* [ ] Migração Flyway (se mexeu em schema)

---

Se ficar qualquer dúvida, manda no chat do time. Bora construir isso junto! 🐀💙
