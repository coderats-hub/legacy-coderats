resource "azurerm_container_app_environment" "main" {
  name                       = local.container_apps_env_name
  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  tags                       = local.common_tags
}

resource "azurerm_container_app" "backend" {
  name                         = local.backend_container_app_name
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"
  tags                         = local.common_tags

  identity {
    type = "SystemAssigned"
  }

  template {
    min_replicas = var.backend_min_replicas
    max_replicas = var.backend_max_replicas

    container {
      name   = "backend"
      image  = var.backend_image
      cpu    = var.backend_cpu
      memory = var.backend_memory

      env {
        name  = "SERVER_PORT"
        value = tostring(var.backend_port)
      }

      env {
        name  = "SPRING_PROFILES_ACTIVE"
        value = local.backend_profile
      }

      env {
        name  = "DB_URL"
        value = "jdbc:postgresql://${azurerm_postgresql_flexible_server.main.fqdn}:5432/${azurerm_postgresql_flexible_server_database.app.name}?sslmode=require"
      }

      env {
        name  = "DB_USER"
        value = var.postgres_admin_username
      }

      env {
        name  = "SECURITY_JWT_EXPIRATION_MS"
        value = tostring(var.security_jwt_expiration_ms)
      }

      env {
        name  = "CORS_ALLOWED_ORIGINS"
        value = join(",", var.cors_allowed_origins)
      }

      env {
        name  = local.github_client_id_env_name
        value = var.github_oauth_client_id
      }

      env {
        name  = local.github_redirect_uri_env_name
        value = var.github_oauth_redirect_uri
      }

      env {
        name  = "OPENAI_BASE_URL"
        value = var.openai_base_url
      }

      env {
        name  = "OPENAI_CHAT_ENDPOINT"
        value = var.openai_chat_endpoint
      }

      env {
        name  = "OPENAI_MODEL"
        value = var.openai_model
      }

      env {
        name  = "OPENAI_SYSTEM_PROMPT"
        value = var.openai_system_prompt
      }

      env {
        name  = "STORAGE_PROVIDER"
        value = "azure-blob"
      }

      env {
        name  = "AZURE_STORAGE_ACCOUNT"
        value = azurerm_storage_account.images.name
      }

      env {
        name  = "AZURE_STORAGE_CONTAINER"
        value = azurerm_storage_container.images.name
      }

      env {
        name  = "AZURE_STORAGE_BASE_PATH"
        value = var.storage_base_path
      }

      env {
        name  = "AZURE_STORAGE_PUBLIC_BASE_URL"
        value = local.storage_public_base_url
      }

      env {
        name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        value = azurerm_application_insights.main.connection_string
      }
    }
  }

  ingress {
    external_enabled = var.environment != "prod"
    target_port      = var.backend_port
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].container[0].image,
    ]
  }
}

resource "azurerm_role_assignment" "backend_acr_pull" {
  scope                            = azurerm_container_registry.main.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_container_app.backend.identity[0].principal_id
  skip_service_principal_aad_check = true
}
