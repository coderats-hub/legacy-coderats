# CodeRats Azure Terraform

Esta pasta define a infraestrutura Azure inicial do CodeRats com Terraform.

O objetivo desta issue e criar a base dev/staging para a migracao AWS para Azure. A infra AWS antiga nao e referencia operacional e nenhum recurso AWS e criado aqui.

## Recursos Criados

- Resource Group
- Azure Container Registry
- Azure Database for PostgreSQL Flexible Server
- Database PostgreSQL da aplicacao
- Storage Account para imagens
- Blob Container `coderats-images`
- Azure Key Vault
- Log Analytics Workspace
- Application Insights
- Azure Container Apps Environment
- Container App inicial do backend com imagem placeholder

## Pre-requisitos

- Azure CLI instalada
- Terraform instalado
- Login Azure ativo
- Subscription correta selecionada

```bash
az login
az account set --subscription <subscription-id>
az account show
terraform version
```

O provider `azurerm` usa a autenticacao ativa do Azure CLI ou as variaveis padrao suportadas pelo Terraform. Nao coloque `subscription_id`, `tenant_id` ou credenciais nos arquivos versionados.

## Configuracao Local

Copie o exemplo para um arquivo local:

```bash
cd infra/azure/terraform
cp terraform.tfvars.example terraform.tfvars
```

Edite `terraform.tfvars` e troque os placeholders.

Valores em `terraform.tfvars` sobrescrevem os defaults de `variables.tf`. Se precisar mudar a regiao, altere `location` no `terraform.tfvars` local.

Nunca commite:

- `terraform.tfvars`
- `*.auto.tfvars`
- `*.tfstate`
- `.terraform/`
- secrets reais

Neste projeto, `.terraform.lock.hcl` esta ignorado por enquanto. A decisao de versionar o lock file pode ser revista depois do primeiro `terraform init` oficial do projeto.

## Comandos

Formatar:

```bash
terraform fmt -recursive
```

Inicializar:

```bash
terraform init
```

Validar:

```bash
terraform validate
```

Planejar:

```bash
terraform plan
```

Aplicar:

```bash
terraform apply
```

Destruir ambiente dev:

```bash
terraform destroy
```

Nao execute `terraform apply` ou `terraform destroy` sem revisar o plano. `destroy` remove banco, blobs e demais recursos do ambiente.

## Variaveis Principais

- `project_name`
- `environment`
- `location`
- `name_suffix`
- `tags`
- `backend_image`
- `backend_port`
- `postgres_admin_username`
- `postgres_admin_password`
- `postgres_database_name`
- `postgres_location`
- `postgres_name_suffix`
- `storage_container_name`
- `storage_base_path`
- `cors_allowed_origins`
- `github_oauth_client_id`
- `github_oauth_redirect_uri`

`postgres_admin_password` e sensivel e deve ser definida apenas em `terraform.tfvars` local ou em secrets do pipeline.

## Outputs

Os outputs expostos incluem:

- `resource_group_name`
- `acr_name`
- `acr_login_server`
- `postgres_host`
- `postgres_database_name`
- `storage_account_name`
- `storage_container_name`
- `storage_public_base_url`
- `key_vault_name`
- `log_analytics_workspace_id`
- `log_analytics_workspace_name`
- `application_insights_name`
- `application_insights_connection_string`
- `application_insights_instrumentation_key`
- `container_app_environment_name`
- `backend_container_app_name`
- `backend_url`

Senhas, tokens e secrets reais nao sao expostos em outputs.

## PostgreSQL

O Terraform cria um Azure Database for PostgreSQL Flexible Server e a database da aplicacao.

O backend deve usar:

```text
DB_URL=jdbc:postgresql://<postgres-host>:5432/<database>?sslmode=require
DB_USER=<postgres_admin_username>
DB_PASS=<secret>
```

O servidor inicia com rede publica habilitada para simplificar dev/staging. O firewall `0.0.0.0` permite conexoes de servicos Azure. Regras de IP locais ou rede privada devem ser adicionadas quando o modelo de acesso for definido.

Em assinaturas Education, o PostgreSQL Flexible Server pode ser bloqueado em algumas regioes mesmo quando os outros recursos funcionam. Se `terraform apply` retornar `LocationIsOfferRestricted`, configure `postgres_location` no `terraform.tfvars` para uma regiao permitida, por exemplo:

```hcl
postgres_location = "northcentralus"
```

Se `postgres_location` ficar vazio, o Terraform usa o valor de `location`.

Se uma tentativa falhada deixar o nome do Flexible Server reservado em uma regiao bloqueada, defina tambem um sufixo exclusivo para o PostgreSQL:

```hcl
postgres_name_suffix = "gug04"
```

Isso altera apenas o nome do PostgreSQL. Os nomes de ACR, Storage Account e Key Vault continuam usando `name_suffix`.

## Controle de Custo do PostgreSQL

O PostgreSQL Flexible Server e o principal custo recorrente desta infra. Para reduzir consumo dos creditos de estudante, existe um workflow em:

```text
.github/workflows/azure-postgres-scheduler.yml
```

Esse workflow:

- roda a cada hora e para o banco dev se nao houver janela ativa de uso;
- permite start/stop/status manual pelo GitHub Actions;
- pode ser chamado por um workflow de deploy para iniciar o banco antes do deploy;
- usa a tag `keepRunningUntil` no servidor para evitar auto-stop durante uma janela manual ou de deploy.

Configure no GitHub:

- Secret `AZURE_CREDENTIALS` com credenciais de Service Principal para o Resource Group.
- Variable `AZURE_RESOURCE_GROUP`, opcional. Default: `rg-coderats-dev`.
- Variable `AZURE_POSTGRES_SERVER`, opcional. Default: `psql-coderats-dev-gug04`.

Exemplo para criar um Service Principal com escopo limitado ao Resource Group:

```bash
az ad sp create-for-rbac \
  --name coderats-github-actions-dev \
  --role Contributor \
  --scopes /subscriptions/<subscription-id>/resourceGroups/rg-coderats-dev \
  --json-auth
```

Salve o JSON retornado no secret `AZURE_CREDENTIALS`. Nao commite esse valor.

Para ligar manualmente:

1. Abra GitHub Actions.
2. Execute `Azure PostgreSQL Scheduler`.
3. Use `action=start`.
4. Defina `keep_running_minutes`, por exemplo `240`.

O cron nao vai parar o banco antes do horario salvo em `keepRunningUntil`.

Para um workflow de deploy manter o banco ligado durante a publicacao, adicione um job reutilizando o workflow:

```yaml
jobs:
  start-postgres:
    uses: ./.github/workflows/azure-postgres-scheduler.yml
    with:
      action: start
      keep_running_minutes: 120
    secrets: inherit

  deploy:
    needs: start-postgres
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        run: echo "deploy aqui"
```

O Terraform ignora apenas as tags operacionais usadas por esse scheduler no PostgreSQL para evitar drift desnecessario.

## Deploy via GitHub Actions

O workflow principal em `.github/workflows/main.yml` foi preparado para Azure:

- builda a imagem Docker do backend;
- publica no Azure Container Registry;
- inicia o PostgreSQL antes do deploy usando o scheduler;
- configura secrets sensiveis no Container App;
- atualiza o Azure Container App para a imagem publicada;
- gera artefatos Android, iOS e Web sem publicar em servicos AWS.

Secrets obrigatorios no GitHub Actions:

- `AZURE_CREDENTIALS`: JSON do Service Principal.
- `DB_PASS`: senha atual do PostgreSQL.
- `SECURITY_JWT_SECRET`: segredo JWT da aplicacao.
- `GITHUB_OAUTH_CLIENT_SECRET`: secret do OAuth GitHub.
- `OPENAI_API_KEY`: chave da OpenAI ou endpoint compativel.

Variables opcionais no GitHub Actions:

- `AZURE_RESOURCE_GROUP`, default `rg-coderats-dev`.
- `AZURE_ACR_NAME`, default `crcoderatsdevgug01`.
- `AZURE_CONTAINER_APP_NAME`, default `ca-coderats-dev-backend`.
- `AZURE_POSTGRES_SERVER`, default `psql-coderats-dev-gug04`.

O Service Principal usado por `AZURE_CREDENTIALS` precisa conseguir:

- autenticar no Azure;
- fazer push no ACR;
- atualizar o Container App;
- iniciar/parar o PostgreSQL Flexible Server;
- atualizar tags do PostgreSQL usadas pelo scheduler.

Para dev, o papel `Contributor` no Resource Group `rg-coderats-dev` e suficiente e mantem o escopo restrito ao ambiente.

## Storage

O Terraform cria uma Storage Account e um Blob Container para imagens.

Variaveis de runtime esperadas:

```text
STORAGE_PROVIDER=azure-blob
AZURE_STORAGE_ACCOUNT=<storage_account_name>
AZURE_STORAGE_CONTAINER=<storage_container_name>
AZURE_STORAGE_BASE_PATH=public/images/
AZURE_STORAGE_PUBLIC_BASE_URL=https://<account>.blob.core.windows.net/<container>/
```

O container usa acesso publico do tipo `blob`, permitindo leitura publica de blobs sem listagem publica do container.

## Key Vault

O Key Vault e criado sem secrets reais. Configure os secrets manualmente ou via pipeline.

Secrets esperados:

- `DB-PASS`
- `SECURITY-JWT-SECRET`
- `GITHUB-OAUTH-CLIENT-SECRET`
- `OPENAI-API-KEY`
- `AZURE-STORAGE-CONNECTION-STRING`, apenas se a aplicacao precisar temporariamente

Exemplo:

```bash
az keyvault secret set --vault-name <key-vault-name> --name DB-PASS --value "<valor>"
az keyvault secret set --vault-name <key-vault-name> --name SECURITY-JWT-SECRET --value "<valor>"
az keyvault secret set --vault-name <key-vault-name> --name GITHUB-OAUTH-CLIENT-SECRET --value "<valor>"
az keyvault secret set --vault-name <key-vault-name> --name OPENAI-API-KEY --value "<valor>"
```

O Terraform concede permissoes de secret ao principal que executa o provisionamento. A integracao do Container App com Key Vault pode ser refinada na etapa de CD, quando a estrategia final de secrets estiver definida.

## Container App Backend

O Container App usa `backend_image` como imagem configuravel.

Default:

```text
mcr.microsoft.com/azuredocs/containerapps-helloworld:latest
```

A Issue 6 deve:

- buildar a imagem real do backend;
- publicar no ACR;
- atualizar o Container App com `<acr-login-server>/coderats-backend:<tag>`;
- configurar a injecao dos secrets no runtime;
- automatizar deploy por pipeline.

Variaveis nao sensiveis ja preparadas no Container App:

- `SERVER_PORT`
- `SPRING_PROFILES_ACTIVE`
- `DB_URL`
- `DB_USER`
- `SECURITY_JWT_EXPIRATION_MS`
- `CORS_ALLOWED_ORIGINS`
- `GITHUB_OAUTH_CLIENT_ID_DEV` ou `GITHUB_OAUTH_CLIENT_ID_PROD`
- `GITHUB_OAUTH_REDIRECT_URI_DEV` ou `GITHUB_OAUTH_REDIRECT_URI_PROD`
- `OPENAI_BASE_URL`
- `OPENAI_CHAT_ENDPOINT`
- `OPENAI_MODEL`
- `OPENAI_SYSTEM_PROMPT`
- `STORAGE_PROVIDER`
- `AZURE_STORAGE_ACCOUNT`
- `AZURE_STORAGE_CONTAINER`
- `AZURE_STORAGE_BASE_PATH`
- `AZURE_STORAGE_PUBLIC_BASE_URL`
- `APPLICATIONINSIGHTS_CONNECTION_STRING`

Variaveis sensiveis como `DB_PASS`, `SECURITY_JWT_SECRET`, `GITHUB_OAUTH_CLIENT_SECRET_*` e `OPENAI_API_KEY` nao sao colocadas no Terraform.

## Observabilidade

O Log Analytics Workspace e o Application Insights sao provisionados e conectados aos recursos de Container Apps.

O backend ainda nao e obrigado a usar SDK do Application Insights. Os outputs ficam disponiveis para uma etapa posterior de instrumentacao.

## Relacao Com Issues Anteriores

Issue 4:

O backend passa a usar Azure Blob Storage para imagens. Os outputs `storage_account_name`, `storage_container_name` e `storage_public_base_url` alimentam as variaveis de runtime.

Issue 6:

O pipeline usa `acr_login_server`, `backend_container_app_name`, `container_app_environment_name` e `resource_group_name` para publicar e promover a imagem real do backend.
