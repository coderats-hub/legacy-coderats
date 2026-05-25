resource "azurerm_storage_account" "images" {
  name                            = local.storage_account_name
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = true
  tags                            = local.common_tags
}

resource "azurerm_storage_container" "images" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.images.name
  container_access_type = "blob"
}
