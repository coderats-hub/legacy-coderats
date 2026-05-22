# Configuracao por Ambiente

## 1. Objetivo

Este documento descreve como configurar o CodeRats para rodar em local, dev, staging e producao sem alterar codigo-fonte.

A regra operacional e:

- backend recebe configuracao por variaveis de ambiente Spring;
- frontend/mobile recebe `BASE_API_URL` por `.env` local ou por `--dart-define` em build;
- CORS e definido por ambiente;
- perfis Spring nao devem apontar para IPs ou dominios AWS como fallback obrigatorio.

## 2. Arquivos de exemplo

Arquivos versionados:

- `Codigo/.env.example`: variaveis para Docker Compose, backend, banco, OAuth, OpenAI, storage e build Flutter Web.
- `Codigo/apps/mobile/.env.example`: variaveis para Flutter Web/Mobile.

Arquivos locais nao devem conter segredos reais versionados.

## 3. Backend

### Variaveis comuns

```env
SPRING_PROFILES_ACTIVE=local
SERVER_PORT=8080
APP_PORT=8080
CORS_ALLOWED_ORIGINS=http://localhost:8081,http://localhost:8082,http://localhost:8080
SECURITY_JWT_SECRET=replace-with-at-least-64-random-characters-for-hs512-signing
SECURITY_JWT_EXPIRATION_MS=86400000
```

### Banco

Local via Docker Compose:

```env
POSTGRES_DB=coderats_db
POSTGRES_USER=coderats_user
POSTGRES_PASSWORD=change-me
DB_URL=jdbc:postgresql://db:5432/coderats_db
DB_USER=coderats_user
DB_PASS=change-me
```

Azure PostgreSQL:

```env
DB_URL=jdbc:postgresql://<server>.postgres.database.azure.com:5432/<database>?sslmode=require
DB_USER=<user>
DB_PASS=<secret>
```

### GitHub OAuth

Local:

```env
GITHUB_OAUTH_CLIENT_ID_LOCAL=<client-id>
GITHUB_OAUTH_CLIENT_SECRET_LOCAL=<secret>
GITHUB_OAUTH_REDIRECT_URI_LOCAL=http://localhost:8080/auth/github/callback
```

Dev:

```env
GITHUB_OAUTH_CLIENT_ID_DEV=<client-id>
GITHUB_OAUTH_CLIENT_SECRET_DEV=<secret>
GITHUB_OAUTH_REDIRECT_URI_DEV=https://<dev-backend-host>/auth/github/callback
```

Staging:

```env
GITHUB_OAUTH_CLIENT_ID_STAGING=<client-id>
GITHUB_OAUTH_CLIENT_SECRET_STAGING=<secret>
GITHUB_OAUTH_REDIRECT_URI_STAGING=https://<staging-backend-host>/auth/github/callback
```

Producao:

```env
GITHUB_OAUTH_CLIENT_ID_PROD=<client-id>
GITHUB_OAUTH_CLIENT_SECRET_PROD=<secret>
GITHUB_OAUTH_REDIRECT_URI_PROD=https://<prod-backend-host>/auth/github/callback
```

### OpenAI

```env
OPENAI_API_KEY=<secret>
OPENAI_BASE_URL=https://api.openai.com/v1
OPENAI_CHAT_ENDPOINT=/chat/completions
OPENAI_MODEL=gpt-4.1-mini
OPENAI_SYSTEM_PROMPT=<prompt>
```

### Storage atual S3-compatible

Enquanto a implementacao Azure Blob nao for feita, o backend ainda usa o cliente S3. Os valores devem ser explicitos por ambiente.

```env
AWS_REGION=us-east-1
AWS_S3_BUCKET=coderats-local-files
AWS_S3_BASE_PATH=public/images/
AWS_S3_PUBLIC_BASE_URL=http://localhost:4566/coderats-local-files
```

## 4. Frontend e mobile

Local:

```env
BASE_API_URL=http://localhost:8080
USE_MOCK_API=false
```

Dev/staging/prod:

```env
BASE_API_URL=https://<backend-host>
USE_MOCK_API=false
```

O app tambem aceita configuracao em tempo de build:

```bash
flutter build web --release --dart-define=BASE_API_URL=https://<backend-host>
```

No Dockerfile do mobile, `BASE_API_URL` e `USE_MOCK_API` entram como build args.

## 5. CORS por ambiente

O backend le `CORS_ALLOWED_ORIGINS`.

Exemplo local:

```env
CORS_ALLOWED_ORIGINS=http://localhost:8081,http://localhost:8082,http://localhost:8080
```

Exemplo dev:

```env
CORS_ALLOWED_ORIGINS=https://<dev-frontend-host>,https://<dev-backend-host>
```

Exemplo staging:

```env
CORS_ALLOWED_ORIGINS=https://<staging-frontend-host>,https://<staging-backend-host>
```

Exemplo producao:

```env
CORS_ALLOWED_ORIGINS=https://<prod-frontend-host>
```

## 6. Validacao local

1. Criar `Codigo/.env` a partir de `Codigo/.env.example`.
2. Criar `Codigo/apps/mobile/.env` a partir de `Codigo/apps/mobile/.env.example`.
3. Subir o ambiente:

```bash
cd Codigo
docker compose up -d --build
```

4. Validar backend:

```bash
curl http://localhost:8080/
```

5. Validar frontend web:

```text
http://localhost:8081
```

6. Validar Flutter dev server:

```bash
docker compose run --service-ports mobile-dev
```

```text
http://localhost:8082
```

## 7. Validacao com backend externo

1. Configurar `BASE_API_URL` no `.env` do mobile:

```env
BASE_API_URL=https://<backend-host>
```

2. Ou buildar o Flutter Web com `--dart-define`:

```bash
flutter build web --release --dart-define=BASE_API_URL=https://<backend-host>
```

3. Configurar CORS no backend externo:

```env
CORS_ALLOWED_ORIGINS=https://<frontend-host>
```

4. Validar login GitHub:

```text
https://<backend-host>/auth/github/login
```

5. Validar chamada autenticada pelo app apos login.

## 8. Pontos removidos do runtime

O runtime nao deve depender de:

- URL de ALB AWS como `BASE_API_URL`;
- URLs AWS em CORS;
- IP publico AWS como fallback de banco;
- dominio AWS no Android `network_security_config.xml`.

URLs AWS podem permanecer documentadas apenas como inventario historico da migracao.
