# Migracao AWS para Azure - Estado Atual e Arquitetura Alvo

## 1. Objetivo

Este documento consolida o estado atual de runtime e infraestrutura do CodeRats antes da migracao da AWS para a Azure.

O repositorio possui configuracoes relevantes de aplicacao, Docker, perfis Spring e variaveis de ambiente, mas nao possui infraestrutura AWS declarada via Terraform, CloudFormation ou CDK. Portanto, a migracao deve partir de:

1. leitura do codigo e das configuracoes versionadas;
2. inventario manual dos recursos AWS existentes;
3. definicao da arquitetura alvo na Azure;
4. criacao de infraestrutura como codigo para o novo ambiente.

## 2. Estado atual do runtime

### Backend

O backend fica em `Codigo/apps/backend`.

Caracteristicas principais:

- Aplicacao Java 21 com Spring Boot 3.4.10.
- Build Maven.
- Runtime em container baseado em `eclipse-temurin:21-jre`.
- Porta padrao: `8080`.
- API REST com Spring Web.
- Persistencia com Spring Data JPA e PostgreSQL.
- Validacao de schema com Hibernate `ddl-auto=validate`.
- Flyway habilitado em `classpath:db/migration`.
- JWT com JJWT e assinatura HMAC-SHA512.
- Swagger UI via Springdoc em `/swagger-ui`.
- Upload de imagens integrado ao AWS S3.
- Integracao com GitHub OAuth/API.
- Integracao com OpenAI API.

Dockerfile atual:

- build stage: `maven:3.9-eclipse-temurin-21`;
- runtime stage: `eclipse-temurin:21-jre`;
- jar copiado para `/app/app.jar`;
- entrypoint: `java -jar /app/app.jar`.

### Frontend Flutter Web / Mobile

O app fica em `Codigo/apps/mobile`.

Caracteristicas principais:

- Flutter/Dart.
- Pode rodar como app mobile e como Flutter Web.
- Flutter Web e compilado em modo release.
- Build containerizado usando `ghcr.io/cirruslabs/flutter:3.24.3`.
- Runtime web servido por `nginx:alpine`.
- Porta do NGINX: `8080`.
- SPA fallback configurado com `try_files $uri $uri/ /index.html`.

O arquivo `Codigo/apps/mobile/.env` deve apontar para o backend do ambiente. Para desenvolvimento local, o valor esperado e:

```env
BASE_API_URL=http://localhost:8080
```

Para dev, staging e producao, `BASE_API_URL` deve ser configurado no `.env` do app ou no build via `--dart-define=BASE_API_URL=...`.

### Banco de dados

O banco central esperado pela aplicacao e PostgreSQL.

Configuracoes atuais:

- Docker Compose local usa `postgres:16`.
- Backend usa `DB_URL`, `DB_USER` e `DB_PASS`.
- Os perfis Spring leem `DB_URL`, `DB_USER` e `DB_PASS` por ambiente.
- O perfil local usa fallback para PostgreSQL local.
- Os perfis staging/prod exigem `DB_URL`, `DB_USER` e `DB_PASS` configurados no ambiente.

```text
jdbc:postgresql://localhost:5432/coderats_db
```

Ponto de atencao:

- A documentacao menciona migrations Flyway em `src/main/resources/db/migration`, mas essa pasta nao existe no estado atual do repositorio.
- Como `spring.jpa.hibernate.ddl-auto=validate`, um ambiente novo falhara se o schema nao existir ou se as migrations reais nao forem recuperadas/criadas.
- Existe `Artefatos/coderats.sql`, mas ele e um artefato antigo gerado pelo MySQL Workbench e nao representa diretamente o schema PostgreSQL atual das entidades JPA.

### Storage de imagens

O storage atual usa AWS S3.

Configuracoes atuais:

- Regiao default local: `us-east-1`.
- Bucket default local: `coderats-local-files`.
- Base path default: `public/images/`.
- Public base URL default local: `http://localhost:4566/coderats-local-files`.

O backend usa `S3Client` da AWS SDK e envia objetos com ACL `PUBLIC_READ`.

### Docker Compose local

Arquivo: `Codigo/docker-compose.yml`.

Servicos:

- `db`: PostgreSQL 16.
- `pgadmin`: administracao visual do banco.
- `backend`: build de `./apps/backend`.
- `mobile`: build de `./apps/mobile`, servido por NGINX.
- `mobile-dev`: container Flutter para desenvolvimento web com hot reload.

Volumes:

- `pgdata`
- `pgadmin`

## 3. Variaveis de ambiente

### Aplicacao backend

```env
SERVER_PORT=8080
SPRING_PROFILES_ACTIVE=dev
APP_PORT=8080
```

### Banco de dados

```env
POSTGRES_DB=coderats_db
POSTGRES_USER=coderats_user
POSTGRES_PASSWORD=<secret>
DB_URL=jdbc:postgresql://<host>:5432/<database>
DB_USER=<user>
DB_PASS=<secret>
DB_PORT=5432
```

Para Azure Database for PostgreSQL, a URL deve usar SSL:

```env
DB_URL=jdbc:postgresql://<server>.postgres.database.azure.com:5432/<database>?sslmode=require
```

### PgAdmin local

```env
PGADMIN_DEFAULT_EMAIL=admin@local.dev
PGADMIN_DEFAULT_PASSWORD=<secret>
PGADMIN_PORT=5050
```

PgAdmin e apenas ferramenta local/dev e nao deve ser componente obrigatorio de producao.

### JWT

```env
SECURITY_JWT_SECRET=<secret-com-tamanho-suficiente-para-HS512>
SECURITY_JWT_EXPIRATION_MS=86400000
```

### GitHub OAuth

```env
GITHUB_OAUTH_CLIENT_ID_LOCAL=<secret>
GITHUB_OAUTH_CLIENT_SECRET_LOCAL=<secret>
GITHUB_OAUTH_REDIRECT_URI_LOCAL=http://localhost:8080/auth/github/callback

GITHUB_OAUTH_CLIENT_ID_DEV=<secret>
GITHUB_OAUTH_CLIENT_SECRET_DEV=<secret>
GITHUB_OAUTH_REDIRECT_URI_DEV=https://<dev-backend-host>/auth/github/callback

GITHUB_OAUTH_CLIENT_ID_STAGING=<secret>
GITHUB_OAUTH_CLIENT_SECRET_STAGING=<secret>
GITHUB_OAUTH_REDIRECT_URI_STAGING=https://<staging-backend-host>/auth/github/callback

GITHUB_OAUTH_CLIENT_ID_PROD=<secret>
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

### AWS S3 atual

```env
AWS_REGION=us-east-1
AWS_S3_BUCKET=coderats-local-files
AWS_S3_BASE_PATH=public/images/
AWS_S3_PUBLIC_BASE_URL=http://localhost:4566/coderats-local-files
```

### Azure Blob Storage alvo

Variaveis sugeridas para substituir S3:

```env
AZURE_STORAGE_ACCOUNT=<account>
AZURE_STORAGE_CONTAINER=<container>
AZURE_STORAGE_BASE_PATH=public/images/
AZURE_STORAGE_PUBLIC_BASE_URL=https://<account>.blob.core.windows.net/<container>
AZURE_STORAGE_CONNECTION_STRING=<secret>
```

Preferencia de producao:

- usar Managed Identity em vez de connection string quando o servico de compute escolhido suportar;
- manter secrets no Azure Key Vault.

### Frontend Flutter

```env
BASE_API_URL=https://<backend-public-url>
USE_MOCK_API=false
DEFAULT_GROUP_ID=<opcional>
ADMOB_BANNER_ANDROID=<id>
ADS_ENV=<dev|staging|prod>
ADSENSE_CLIENT=<opcional>
ADSENSE_SLOT=<opcional>
ADSENSE_CLIENT_TEST=<opcional>
ADSENSE_SLOT_TEST=<opcional>
GIT_BRANCH=<branch>
BRANCH=<branch>
```

## 4. Integracoes externas

### GitHub

Uso atual:

- autenticacao OAuth;
- leitura de perfil do usuario;
- leitura de email principal;
- leitura de commits/repositorios para avaliacao.

Endpoints externos usados:

- `https://github.com/login/oauth/authorize`
- `https://github.com/login/oauth/access_token`
- `https://api.github.com/user`
- `https://api.github.com/user/emails`

Scope OAuth:

```text
read:user user:email repo
```

Impacto na migracao:

- atualizar callback URL no GitHub OAuth App para o dominio Azure;
- garantir saida HTTPS do backend para GitHub;
- avaliar armazenamento do `github_access_token` em banco.

### OpenAI

Uso atual:

- avaliacao de commits;
- retorno esperado em JSON com `points` e `summary_ai`.

Impacto na migracao:

- manter `OPENAI_API_KEY` em Key Vault;
- garantir saida HTTPS para `api.openai.com`;
- observar custo, timeout e retry em chamadas de IA.

### AWS S3

Uso atual:

- upload de imagens;
- objetos publicos via URL;
- ACL `PUBLIC_READ`.

Impacto na migracao:

- substituir por Azure Blob Storage;
- rever modelo de permissao publica;
- migrar objetos existentes do bucket S3 para container Blob;
- atualizar URLs persistidas no banco se imagens antigas apontarem para S3.

### Ads

Uso atual:

- `google_mobile_ads` no app mobile;
- `ADMOB_BANNER_ANDROID` no `.env`;
- suporte a variaveis AdSense em componentes web.

Impacto na migracao:

- nao depende diretamente da AWS;
- validar dominios web autorizados no Google AdSense/AdMob se o frontend mudar de dominio.

## 5. URLs AWS conhecidas

As seguintes URLs AWS aparecem no repositorio:

```text
http://coderats-dev-alb-687982124.us-east-2.elb.amazonaws.com
http://coderats-web-estatico-dev.s3-website.us-east-2.amazonaws.com
http://coderats-web-estatico-stg.s3-website.us-east-2.amazonaws.com/
https://coderats-files-starter.s3.us-east-2.amazonaws.com
jdbc:postgresql://3.128.30.149:5432/coderats_db
```

Arquivos onde aparecem:

- `Codigo/apps/backend/src/main/resources/application.properties`
- `Codigo/apps/backend/src/main/resources/application-dev.properties`
- `Codigo/apps/backend/src/main/resources/application-local.properties`
- `Codigo/apps/backend/src/main/resources/application-prod.properties`
- `Codigo/apps/mobile/.env`
- `Codigo/apps/mobile/android/app/src/main/res/xml/network_security_config.xml`

Essas referencias devem ser substituidas por variaveis de ambiente ou URLs Azure por ambiente.

## 6. Mapeamento AWS atual para Azure alvo

| Necessidade | AWS atual/conhecida | Azure alvo recomendado |
| --- | --- | --- |
| Backend container Spring Boot | ALB apontando para runtime nao declarado no repo | Azure Container Apps ou Azure App Service for Containers |
| Imagem Docker | Nao declarado no repo | Azure Container Registry |
| Frontend Flutter Web estatico | S3 static website | Azure Static Web Apps ou Azure Storage Static Website + Azure CDN/Front Door |
| Banco PostgreSQL | IP publico `3.128.30.149` ou recurso AWS externo ao repo | Azure Database for PostgreSQL Flexible Server |
| Storage de imagens | AWS S3 | Azure Blob Storage |
| Secrets | Nao declarado no repo | Azure Key Vault |
| Logs e metricas | Nao declarado no repo | Azure Monitor + Log Analytics + Application Insights |
| DNS/TLS | Nao declarado no repo | Azure DNS + Managed Certificates, ou Azure Front Door |
| Cache de estado OAuth | Memoria do processo | Azure Cache for Redis se houver mais de uma replica |
| CI/CD | Documentacao cita GitHub Actions, mas nao ha workflow versionado | GitHub Actions com deploy para Azure |

## 7. Arquitetura alvo inicial na Azure

Arquitetura recomendada para primeira migracao:

1. Azure Container Registry para armazenar imagem do backend.
2. Azure Container Apps para executar o backend Spring Boot.
3. Azure Database for PostgreSQL Flexible Server para banco principal.
4. Azure Blob Storage para imagens de usuarios, grupos e check-ins.
5. Azure Static Web Apps para o Flutter Web, ou Storage Static Website se o build for puramente estatico.
6. Azure Key Vault para segredos.
7. Managed Identity para acesso do backend a Key Vault e, se possivel, Blob Storage.
8. Azure Monitor, Log Analytics e Application Insights para logs, traces e metricas.
9. Azure Cache for Redis somente se o backend rodar com multiplas replicas ou se o fluxo OAuth precisar ser resiliente a restart.

Alternativa para backend:

- Azure App Service for Containers tambem e viavel e pode ser mais simples para operacao inicial.
- Azure Container Apps e preferivel se houver expectativa de escalar containers, usar revisions, jobs ou padrao mais cloud-native sem gerenciar Kubernetes.

## 8. Ambientes iniciais

### dev

Objetivo:

- validar build, deploy e integracoes basicas;
- permitir testes de desenvolvimento sem afetar usuarios finais.

Caracteristicas:

- menor SKU de banco;
- storage separado;
- secrets separados;
- OAuth GitHub app de desenvolvimento;
- CORS apontando para frontend dev;
- logs com retencao curta.

### staging

Objetivo:

- validar migracao, schema, dados e release candidate antes de producao.

Caracteristicas:

- configuracao proxima de producao;
- banco separado, com snapshot/anonymized dump quando necessario;
- storage separado;
- OAuth callback proprio;
- testes de smoke e regressao.

### prod

Objetivo:

- ambiente publico final.

Caracteristicas:

- banco com backup automatico;
- TLS obrigatorio;
- secrets exclusivos;
- observabilidade ativa;
- politicas de acesso mais restritivas;
- controle de CORS apenas para dominios oficiais;
- plano de rollback definido.

## 9. Riscos conhecidos

1. Ausencia de IaC AWS no repositorio.
   - A infraestrutura atual precisa ser inventariada manualmente na AWS antes do desenho final.

2. Ausencia de migrations Flyway no caminho configurado.
   - O schema PostgreSQL atual precisa ser recuperado do banco existente ou recriado em migrations antes do deploy Azure.

3. Defaults apontando para AWS.
   - Ha URL de ALB, S3 website, S3 bucket e IP publico de banco em arquivos versionados.

4. Modelo de storage muda de S3 para Blob.
   - ACL `PUBLIC_READ` nao deve ser copiada automaticamente; e necessario definir modelo de acesso publico, SAS, CDN ou proxy.

5. URLs de imagens podem estar persistidas no banco.
   - Se registros existentes apontam para S3, sera preciso migrar dados ou manter compatibilidade temporaria.

6. Estado OAuth em memoria.
   - `EphemeralStore` usa `ConcurrentHashMap`. Com mais de uma replica, restart ou deploy rolling, codigos de login podem se perder.

7. Autorizacao permissiva.
   - `SecurityConfig` usa `anyRequest().permitAll()`. O JWT e processado, mas a protecao depende de validacoes manuais.

8. Healthcheck fraco.
   - O backend tem `GET /` retornando `Hello World`, mas nao ha Spring Actuator versionado para probes de readiness/liveness.

9. CORS estatico.
   - Origens permitidas estao hardcoded em properties e precisam variar por ambiente.

10. Segredos e tokens.
    - `github_access_token` e persistido no banco. Revisar criptografia, rotacao e escopo antes de producao.

11. Mobile Android.
    - `network_security_config.xml` referencia dominio AWS antigo. Precisa ser atualizado para Azure se o app Android for distribuido.

12. GitHub OAuth callback.
    - O callback precisa ser atualizado no GitHub OAuth App para cada ambiente Azure.

## 10. Decisao de infraestrutura como codigo

Recomendacao inicial: Terraform.

Motivos:

- e multi-cloud e facilita documentar claramente a migracao AWS -> Azure;
- tem bom suporte a Azure Resource Manager;
- e familiar para times DevOps/Platform;
- permite criar modulos por dominio: network, compute, database, storage, observability e secrets;
- facilita separar `dev`, `staging` e `prod` por workspaces, pastas ou stacks.

Alternativa aceitavel: Bicep.

Quando escolher Bicep:

- se o time quiser uma abordagem 100% Azure-native;
- se a operacao for permanecer exclusivamente em Azure;
- se houver maior familiaridade com ARM/Bicep do que Terraform.

Decisao proposta para esta migracao:

```text
Usar Terraform como ferramenta principal de IaC para a Azure.
```

## 11. Pendencias para proximas issues

1. Criar ou recuperar migrations PostgreSQL reais.
2. Implementar storage Azure Blob no backend.
3. Remover referencias AWS hardcoded.
4. Adicionar Spring Actuator para health/readiness.
5. Externalizar CORS por ambiente.
6. Definir pipeline GitHub Actions para build e deploy.
7. Criar Terraform para dev.
8. Replicar Terraform para staging/prod.
9. Planejar migracao de dados PostgreSQL.
10. Planejar migracao de objetos S3 para Blob Storage.
