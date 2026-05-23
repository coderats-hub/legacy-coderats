# 09 - Storage de imagens: Azure Blob Storage

Este documento descreve a troca/abstração do storage de imagens do sistema, migrando o provider padrão para Azure Blob Storage.

Resumo:
- Provider padrão: `azure-blob`.

Observação: o suporte a AWS S3 foi removido do código-base — a infraestrutura AWS não está mais disponível, portanto a solução foi migrada completamente para Azure Blob Storage.

Como funciona:
- O backend depende de uma interface `ImageStorageService`.
Implementação disponível:
- `AzureBlobImageStorageService` (padrão)

Variáveis de ambiente (exemplo em `Codigo/.env.example`):

`STORAGE_PROVIDER` — `azure-blob` (padrão). Valores alternativos não são suportados (S3 removido).

Azure (quando `STORAGE_PROVIDER=azure-blob`):
- `AZURE_STORAGE_CONNECTION_STRING` — (opcional) connection string para dev/local.
- `AZURE_STORAGE_ACCOUNT` — nome da conta (obrigatório quando connection string não estiver presente).
- `AZURE_STORAGE_CONTAINER` — container (default `coderats-images`).
- `AZURE_STORAGE_BASE_PATH` — base path dentro do container (default `public/images/`).
- `AZURE_STORAGE_PUBLIC_BASE_URL` — base pública (opcional). Se não fornecida, a URL do blob será retornada pelo SDK.

Autenticação suportada:
- Se `AZURE_STORAGE_CONNECTION_STRING` estiver definida: usa connection string.
- Caso contrário: usa `DefaultAzureCredential` (ex.: managed identity) e monta o endpoint `https://<account>.blob.core.windows.net`.

Endpoint e formato de resposta:
- O endpoint de upload existente continua: `POST /uploads/images` (multipart `file`).
- Resposta (sem alteração):
```
HTTP 201
{
  "url": "https://<account>.blob.core.windows.net/<container>/public/images/<uuid>.png",
  "key": "public/images/<uuid>.png",
  "targetType": null,
  "entityId": null
}
```

Observações:
- Não commitar secrets.
- Em produção no Azure recomenda-se o uso de identidades gerenciadas (DefaultAzureCredential) com permissões mínimas.
- Evitar usar SAS expirável como URL permanente.

Validação local:
- Para dev, defina `AZURE_STORAGE_CONNECTION_STRING` e teste com curl ou cliente HTTP.
- Exemplo:
```
curl -X POST -F "file=@./sample.png" http://localhost:8080/uploads/images
```
