output "resource_group_name" {
  description = "Resource Group name."
  value       = azurerm_resource_group.main.name
}

output "acr_name" {
  description = "Azure Container Registry name."
  value       = azurerm_container_registry.main.name
}

output "acr_login_server" {
  description = "Azure Container Registry login server."
  value       = azurerm_container_registry.main.login_server
}

output "postgres_host" {
  description = "PostgreSQL Flexible Server host."
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "postgres_database_name" {
  description = "Application PostgreSQL database name."
  value       = azurerm_postgresql_flexible_server_database.app.name
}

output "storage_account_name" {
  description = "Storage Account name used for images."
  value       = azurerm_storage_account.images.name
}

output "storage_container_name" {
  description = "Blob container name used for images."
  value       = azurerm_storage_container.images.name
}

output "storage_public_base_url" {
  description = "Public base URL for image blobs."
  value       = local.storage_public_base_url
}

output "storage_static_website_endpoint" {
  description = "Static website endpoint for the web app."
  value       = azurerm_storage_account.images.primary_web_endpoint
}

output "key_vault_name" {
  description = "Key Vault name."
  value       = azurerm_key_vault.main.name
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID."
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name."
  value       = azurerm_log_analytics_workspace.main.name
}

output "application_insights_name" {
  description = "Application Insights name."
  value       = azurerm_application_insights.main.name
}

output "application_insights_connection_string" {
  description = "Application Insights connection string."
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key."
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "container_app_environment_name" {
  description = "Azure Container Apps Environment name."
  value       = azurerm_container_app_environment.main.name
}

output "backend_container_app_name" {
  description = "Backend Container App name."
  value       = azurerm_container_app.backend.name
}

output "backend_url" {
  description = "Backend Container App URL when ingress is enabled."
  value       = try("https://${azurerm_container_app.backend.ingress[0].fqdn}", null)
}
