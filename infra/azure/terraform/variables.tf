variable "project_name" {
  description = "Project name used for Azure resource naming."
  type        = string
  default     = "coderats"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{2,20}$", var.project_name))
    error_message = "project_name must contain 2-20 letters, numbers, or hyphens."
  }
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "eastus"
}

variable "name_suffix" {
  description = "Short lowercase suffix for globally unique Azure resource names such as ACR, Storage Account, PostgreSQL, and Key Vault."
  type        = string
  default     = "dev01"

  validation {
    condition     = can(regex("^[a-z0-9]{3,8}$", var.name_suffix))
    error_message = "name_suffix must contain 3-8 lowercase letters or numbers."
  }
}

variable "tags" {
  description = "Additional tags to apply to all supported resources."
  type        = map(string)
  default     = {}
}

variable "acr_sku" {
  description = "Azure Container Registry SKU."
  type        = string
  default     = "Basic"
}

variable "acr_admin_enabled" {
  description = "Whether to enable the ACR admin user. Keep false for normal deployments."
  type        = bool
  default     = false
}

variable "postgres_admin_username" {
  description = "PostgreSQL Flexible Server admin username."
  type        = string
  default     = "coderats_admin"
}

variable "postgres_admin_password" {
  description = "PostgreSQL Flexible Server admin password. Set only in local terraform.tfvars or CI secrets."
  type        = string
  sensitive   = true
}

variable "postgres_database_name" {
  description = "Application database name."
  type        = string
  default     = "coderats_db"
}

variable "postgres_version" {
  description = "PostgreSQL major version."
  type        = string
  default     = "16"
}

variable "postgres_location" {
  description = "Optional Azure region for PostgreSQL Flexible Server. Leave empty to use location. Student subscriptions can restrict PostgreSQL by region."
  type        = string
  default     = ""
}

variable "postgres_name_suffix" {
  description = "Optional suffix used only for PostgreSQL Flexible Server names. Use it when a failed Azure creation keeps the previous PostgreSQL name reserved."
  type        = string
  default     = ""

  validation {
    condition     = var.postgres_name_suffix == "" || can(regex("^[a-z0-9]{3,8}$", var.postgres_name_suffix))
    error_message = "postgres_name_suffix must be empty or contain 3-8 lowercase letters or numbers."
  }
}

variable "postgres_sku_name" {
  description = "PostgreSQL Flexible Server SKU for the initial environment."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgres_zone" {
  description = "Optional availability zone for PostgreSQL Flexible Server. Leave null for Azure/provider default, especially when importing a server created manually."
  type        = string
  default     = null
}

variable "postgres_storage_mb" {
  description = "PostgreSQL storage size in MB."
  type        = number
  default     = 32768
}

variable "storage_container_name" {
  description = "Blob container name for uploaded images."
  type        = string
  default     = "coderats-images"
}

variable "storage_base_path" {
  description = "Base path used by the backend for images in the container."
  type        = string
  default     = "public/images/"
}

variable "key_vault_sku" {
  description = "Azure Key Vault SKU."
  type        = string
  default     = "standard"
}

variable "backend_image" {
  description = "Container image for the backend Container App. Issue 6 will replace the placeholder with the real ACR image."
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}

variable "backend_port" {
  description = "Container port exposed by the backend."
  type        = number
  default     = 8080
}

variable "backend_cpu" {
  description = "CPU allocated to the backend Container App."
  type        = number
  default     = 0.25
}

variable "backend_memory" {
  description = "Memory allocated to the backend Container App."
  type        = string
  default     = "0.5Gi"
}

variable "backend_min_replicas" {
  description = "Minimum backend replicas."
  type        = number
  default     = 0
}

variable "backend_max_replicas" {
  description = "Maximum backend replicas."
  type        = number
  default     = 1
}

variable "cors_allowed_origins" {
  description = "CORS allowed origins passed to the backend."
  type        = list(string)
  default     = ["http://localhost:8081"]
}

variable "github_oauth_client_id" {
  description = "GitHub OAuth client id for this environment. Not sensitive."
  type        = string
  default     = ""
}

variable "github_oauth_redirect_uri" {
  description = "GitHub OAuth redirect URI for this environment."
  type        = string
  default     = ""
}

variable "openai_base_url" {
  description = "OpenAI-compatible API base URL."
  type        = string
  default     = "https://api.openai.com/v1"
}

variable "openai_chat_endpoint" {
  description = "OpenAI-compatible chat completions endpoint."
  type        = string
  default     = "/chat/completions"
}

variable "openai_model" {
  description = "Default OpenAI model name used by the backend."
  type        = string
  default     = "gpt-4.1-mini"
}

variable "openai_system_prompt" {
  description = "Default system prompt for OpenAI calls. Keep generic here; secrets must go to Key Vault."
  type        = string
  default     = ""
}

variable "security_jwt_expiration_ms" {
  description = "JWT expiration in milliseconds."
  type        = number
  default     = 86400000
}
