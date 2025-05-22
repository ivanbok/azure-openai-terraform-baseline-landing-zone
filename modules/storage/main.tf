data "http" "my_ip" {
  url = "https://api.ipify.org"
}

# App Deploy Storage Account
module "app_deploy_storage_account_naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
  suffix  = [var.base_name]
}

resource "azurerm_storage_account" "app" {
  name                     = local.app_deploy_storage_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  account_kind             = "StorageV2"

  https_traffic_only_enabled       = true
  min_tls_version                  = "TLS1_2"
  public_network_access_enabled    = true
  cross_tenant_replication_enabled = false
  shared_access_key_enabled        = true

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = concat([local.my_ip], var.ingress_client_ip)
  }

  tags = var.default_tags
}

resource "azurerm_storage_container" "deploy" {
  name                  = "deploy"
  storage_account_id    = azurerm_storage_account.app.id
  container_access_type = "private"
}

# Diagnostic settings for blob
resource "azurerm_monitor_diagnostic_setting" "app_blob" {
  name                       = "default"
  target_resource_id         = "${azurerm_storage_account.app.id}/blobServices/default"
  log_analytics_workspace_id = var.log_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
}

# Private endpoint for app storage
resource "azurerm_private_endpoint" "app_blob" {
  name                = "pep-${local.app_deploy_storage_name}"
  location            = var.location
  resource_group_name = var.virtual_network_resource_group_name

  subnet_id = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "pep-${local.app_deploy_storage_name}"
    private_connection_resource_id = azurerm_storage_account.app.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name = "pep-${local.app_deploy_storage_name}"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.storage_blob_dns_zone.id,
    ]
  }
  tags = var.default_tags
}

# ML Storage Account
module "ml_deploy_storage_account_naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
  suffix  = ["ml${var.base_name}"]
}

resource "azurerm_storage_account" "ml" {
  name                     = local.ml_storage_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  account_kind             = "StorageV2"

  https_traffic_only_enabled       = true
  min_tls_version                  = "TLS1_2"
  public_network_access_enabled    = true
  cross_tenant_replication_enabled = false
  shared_access_key_enabled        = true

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = concat([local.my_ip], var.ingress_client_ip)
  }
  tags = var.default_tags
}

# Diagnostics
resource "azurerm_monitor_diagnostic_setting" "ml_blob" {
  name                       = "default"
  target_resource_id         = "${azurerm_storage_account.ml.id}/blobServices/default"
  log_analytics_workspace_id = var.log_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
  lifecycle {
    ignore_changes = [
      metric
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "ml_file" {
  name                       = "default"
  target_resource_id         = "${azurerm_storage_account.ml.id}/fileServices/default"
  log_analytics_workspace_id = var.log_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
  lifecycle {
    ignore_changes = [
      metric
    ]
  }
}

# Private Endpoints for ML Storage
resource "azurerm_private_endpoint" "ml_blob" {
  name                = "pep-blob-${local.ml_storage_name}"
  location            = var.location
  resource_group_name = var.virtual_network_resource_group_name

  subnet_id = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "pep-blob-${local.ml_storage_name}"
    private_connection_resource_id = azurerm_storage_account.ml.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name = "pep-blob-${local.ml_storage_name}"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.storage_blob_dns_zone.id,
    ]
  }
  tags = var.default_tags
}

resource "azurerm_private_endpoint" "ml_file" {
  name                = "pep-file-${local.ml_storage_name}"
  location            = var.location
  resource_group_name = var.virtual_network_resource_group_name

  subnet_id = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "pep-file-${local.ml_storage_name}"
    private_connection_resource_id = azurerm_storage_account.ml.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }

  private_dns_zone_group {
    name = "pep-blob-${local.ml_storage_name}"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.storage_file_dns_zone.id,
    ]
  }
  tags = var.default_tags
}

# Private DNS Zones for Storage
resource "azurerm_private_dns_zone" "storage_blob_dns_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.virtual_network_resource_group_name
  tags                = var.default_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob_dns_link" {
  name                  = "privatelink.blob.core.windows.net-link"
  resource_group_name   = var.virtual_network_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob_dns_zone.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
  tags                  = var.default_tags
}

resource "azurerm_private_dns_zone" "storage_file_dns_zone" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.virtual_network_resource_group_name
  tags                = var.default_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_file_dns_link" {
  name                  = "privatelink.file.core.windows.net-link"
  resource_group_name   = var.virtual_network_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.storage_file_dns_zone.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
  tags                  = var.default_tags
}
