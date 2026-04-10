# Arquitetura do Projeto

## 1. Visão geral

O CodeRats está organizado como um monorepo com duas aplicações principais:

* backend em Spring Boot
* aplicativo mobile em Flutter

O objetivo da arquitetura é separar responsabilidades, manter o domínio do negócio legível e permitir evolução sem reescrever a base atual.

## 2. Estrutura macro

A solução real do projeto é formada por quatro blocos:

1. interface do usuário no app mobile
2. API backend para autenticação, grupos, check-ins e integrações
3. persistência central em PostgreSQL
4. persistência e suporte local no mobile com SQLite e preferências salvas

Além disso, a operação do sistema depende de Docker, variáveis de ambiente, Swagger UI, GitHub Actions e armazenamento em S3.

## 3. Backend

O backend usa a seguinte organização prática:

* `web` para controllers, DTOs e tratamento de erro
* `service` para regras de negócio
* `domain` para entidades e modelos persistidos
* `infra` para repositórios e integrações externas
* `security` para JWT e autenticação
* `config` para beans e configuração de S3

O fluxo padrão é simples:

1. o controller recebe a requisição
2. o DTO é validado
3. o service executa a regra de negócio
4. o repository acessa o banco
5. a resposta volta para o cliente

## 4. Front-end mobile

O app Flutter está organizado em:

* `core`
* `database`
* `domain`
* `repositories`
* `services`
* `shared`
* `views`

O ponto de entrada é o `main.dart`, que carrega o `.env`, inicializa sessão, dispara anúncios quando suportado e registra as rotas do aplicativo.

## 5. Fluxo de dados

O projeto trabalha com dois caminhos de dados:

### Online

O mobile consulta a API HTTP, que valida, persiste e responde com os dados do backend.

### Offline ou local

O mobile usa SQLite, `shared_preferences` e a abstração de ambiente em `core/data_environment.dart` para adaptar o comportamento quando não há conectividade ou quando a execução está na web.

## 6. Integrações

As integrações reais do projeto hoje são:

* autenticação JWT
* login e leitura de perfil via GitHub OAuth
* armazenamento de imagem em S3
* avaliação de commits com OpenAI
* documentação da API via Springdoc / Swagger UI

## 7. Infraestrutura e execução

O desenvolvimento local usa Docker e `docker-compose.yml` para subir banco, backend, pgAdmin e mobile web. O backend é configurado por perfis e variáveis de ambiente, e o projeto já tem arquivos separados para local, dev, staging e produção.

## 8. O que foi corrigido na documentação

Este resumo foi escrito para refletir o que existe de fato no código.

Foram evitadas descrições que não batiam com a implementação atual, como:

* uma arquitetura backend em `app/use cases`
* uso de Riverpod no app atual
* pasta `features/` no mobile
* contrato `openapi.yaml` versionado dentro do repositório

## 9. Relação com os outros documentos

* [BACKEND_ARCH.md](./BACKEND_ARCH.md) detalha o backend atual
* [FRONTEND_ARCH.md](./FRONTEND_ARCH.md) detalha o app Flutter atual
* [Documentacao/overview](../Documentacao/overview) concentra a documentação teórica do projeto
