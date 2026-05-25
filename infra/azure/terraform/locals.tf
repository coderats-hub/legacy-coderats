locals {
  project_slug  = lower(replace(var.project_name, "/[^0-9A-Za-z]/", ""))
  name_slug     = lower(replace("${var.project_name}-${var.environment}", "/[^0-9A-Za-z-]/", "-"))
  compact_slug  = lower(replace("${var.project_name}${var.environment}", "/[^0-9A-Za-z]/", ""))
  compact_short = substr(local.compact_slug, 0, 14)

  resource_group_name          = "rg-${local.name_slug}"
  acr_name                     = substr("cr${local.compact_slug}${var.name_suffix}", 0, 50)
  postgres_name_suffix         = var.postgres_name_suffix != "" ? var.postgres_name_suffix : var.name_suffix
  postgres_server_name         = substr("psql-${local.name_slug}-${local.postgres_name_suffix}", 0, 63)
  storage_account_name         = substr("st${local.compact_short}${var.name_suffix}", 0, 24)
  key_vault_name               = substr("kv${local.compact_short}${var.name_suffix}", 0, 24)
  log_analytics_workspace_name = "law-${local.name_slug}"
  application_insights_name    = "appi-${local.name_slug}"
  container_apps_env_name      = "cae-${local.name_slug}"
  backend_container_app_name   = "ca-${local.name_slug}-backend"

  storage_public_base_url = "${azurerm_storage_account.images.primary_blob_endpoint}${azurerm_storage_container.images.name}/"

  backend_profile              = var.environment == "prod" ? "prod" : "dev"
  github_client_id_env_name    = var.environment == "prod" ? "GITHUB_OAUTH_CLIENT_ID_PROD" : "GITHUB_OAUTH_CLIENT_ID_DEV"
  github_redirect_uri_env_name = var.environment == "prod" ? "GITHUB_OAUTH_REDIRECT_URI_PROD" : "GITHUB_OAUTH_REDIRECT_URI_DEV"
  postgres_location            = var.postgres_location != "" ? var.postgres_location : var.location

  common_tags = merge(
    {
      project     = var.project_name
      environment = var.environment
      managed_by  = "terraform"
    },
    var.tags
  )
}
