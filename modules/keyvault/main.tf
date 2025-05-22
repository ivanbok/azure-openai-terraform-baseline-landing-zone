data "azurerm_client_config" "current" {}

data "http" "my_ip" {
  url = "https://api.ipify.org"
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
  suffix  = [var.base_name]
}

resource "azurerm_key_vault" "kv" {
  name                            = local.key_vault_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = "standard"
  soft_delete_retention_days      = 7
  purge_protection_enabled        = true
  enable_rbac_authorization       = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  enabled_for_disk_encryption     = false
  public_network_access_enabled   = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules = concat(
      [local.my_ip_cidr],
      [for ip in var.ingress_client_ip : "${ip}/32"]
    )
  }

  tags = var.default_tags
}

resource "azurerm_monitor_diagnostic_setting" "key_vault_diag" {
  name                       = "default"
  target_resource_id         = azurerm_key_vault.kv.id
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

resource "azurerm_private_endpoint" "key_vault_pep" {
  name                = "pep-${local.key_vault_name}"
  location            = var.location
  resource_group_name = var.virtual_network_resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "pep-${local.key_vault_name}"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name = "pep-${local.key_vault_name}"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.key_vault_dns_zone.id,
    ]
  }
  tags = var.default_tags
}

resource "azurerm_private_dns_zone" "key_vault_dns_zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.virtual_network_resource_group_name
  tags                = var.default_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault_dns_link" {
  name                  = "privatelink.vaultcore.azure.net-link"
  resource_group_name   = var.virtual_network_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault_dns_zone.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
  tags                  = var.default_tags
}

# This is required to provide data plane access to write secrets to the Key Vault
resource "azurerm_role_assignment" "key_vault_secrets_officer" {
  scope              = azurerm_key_vault.kv.id
  role_definition_id = local.key_vault_secrets_officer_id
  principal_id       = data.azurerm_client_config.current.object_id
}
