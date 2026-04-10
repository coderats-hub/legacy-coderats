# Arquitetura do Backend

Este documento descreve a implementação atual do backend do CodeRats no diretório `apps/backend`.

## 1. Visão geral

O backend foi implementado em Java 21 com Spring Boot 3.4.10 e segue uma estrutura modular por responsabilidade, não por feature isolada. O desenho atual é mais próximo de uma arquitetura em camadas com serviços centrais do que de um DDD completo.

As camadas reais do projeto são:

`web -> service -> domain -> infra`

Além disso, existem pacotes de `security` e `config` para autenticação, autorização e configuração de integrações.

## 2. Stack atual

O que está efetivamente em uso hoje:

* Java 21
* Spring Boot 3.4.10
* Spring Web
* Spring Data JPA
* Spring Security
* Flyway
* PostgreSQL
* JJWT para tokens JWT
* Springdoc OpenAPI / Swagger UI
* AWS SDK para S3
* spring-dotenv para variáveis de ambiente

## 3. Estrutura real do código

Os pacotes principais do backend são:

* `web` - controllers, DTOs e `@ControllerAdvice`
* `service` - regras de negócio e orquestração
* `domain` - entidades e modelos persistidos
* `infra` - repositórios, cliente OAuth do GitHub, cache efêmero e segurança JWT
* `security` - filtro JWT e configuração de segurança
* `config` - configuração de S3 e outros beans

Isso é diferente do modelo antigo de `application/use cases`; esse padrão não existe hoje no código.

## 4. Fluxo de requisição

O fluxo atual de uma requisição é:

1. O controller recebe a chamada HTTP.
2. O DTO é validado.
3. O service executa a regra de negócio.
4. O repository acessa o banco via JPA.
5. A resposta é montada e devolvida ao cliente.

## 5. Segurança

A autenticação é feita com JWT.

O backend possui:

* `JwtService` para gerar e validar tokens
* `JwtAuthFilter` para aplicar autenticação nas requisições protegidas
* `SecurityConfig` para definir rotas liberadas e rotas autenticadas

Os tokens são usados principalmente nos fluxos de usuário, grupo e check-in.

## 6. Funcionalidades presentes

O backend já tem suporte para:

* autenticação e perfil de usuário
* grupos e participantes
* check-ins e feed
* likes e comentários em check-ins
* integração com GitHub via OAuth
* armazenamento de imagens em S3
* avaliação de commits com OpenAI

Os controllers existentes refletem isso:

* `AuthController`
* `UserController`
* `GroupController`
* `CheckinController`
* `GitHubIntegrationController`
* `ImageUploadController`
* `RootController`

## 7. Integrações externas

### GitHub

A integração com GitHub está implementada em `infra/http/github` e usa OAuth para autenticar o usuário e coletar dados básicos de perfil.

### OpenAI

O backend também possui serviços de avaliação de commits com OpenAI. A configuração da API está em `application.properties`, junto com o prompt de sistema usado na análise.

### S3

O upload de imagens é integrado ao AWS S3 via `ImageStorageService` e `S3Config`.

## 8. Documentação da API

Não existe um arquivo `openapi.yaml` versionado dentro deste diretório no estado atual.

A documentação da API é exposta pelo Springdoc em:

* `/swagger-ui`
* `/v3/api-docs`

## 9. Banco e migrações

O banco usado é PostgreSQL, com validação do schema via Flyway.

Configurações importantes que já estão no projeto:

* `spring.jpa.hibernate.ddl-auto=validate`
* `spring.flyway.enabled=true`
* `spring.flyway.locations=classpath:db/migration`

## 10. Configuração por ambiente

O backend lê variáveis do ambiente e também pode importar `.env`.

Os perfis de execução hoje estão organizados em:

* `application.properties`
* `application-dev.properties`
* `application-staging.properties`
* `application-prod.properties`
* `application-local.properties`

## 11. Correções em relação à versão anterior

Este documento não descreve mais uma arquitetura fictícia com `package-by-feature` e camada `app`.

O que foi atualizado para a realidade do projeto:

* removido o modelo `Controller -> Application -> Domain -> Infrastructure`
* substituído por `web -> service -> domain -> infra`
* removida a referência a `openapi.yaml` inexistente no repositório
* incluídas as integrações reais com GitHub, OpenAI e S3

