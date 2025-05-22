data "http" "my_ip" {
  url = "https://api.ipify.org"
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
  suffix  = [var.base_name]
}

resource "azurerm_container_registry" "acr" {
  name                          = local.container_registry_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = true
  zone_redundancy_enabled       = true

  network_rule_set {
    default_action = "Deny"
    ip_rule = concat(
      [
        {
          ip_range = local.my_ip_cidr
          action   = "Allow"
        }
      ],
      [
        for ip in var.ingress_client_ip : {
          ip_range = "${ip}/32"
          action   = "Allow"
        }
      ]
    )
  }

  data_endpoint_enabled = false
  export_policy_enabled = true
  trust_policy_enabled  = false

  tags = var.default_tags
}

# Diagnostic settings for ACR
resource "azurerm_monitor_diagnostic_setting" "acr_diag" {
  name                       = "default"
  target_resource_id         = azurerm_container_registry.acr.id
  log_analytics_workspace_id = var.log_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
}

resource "azurerm_private_endpoint" "acr_pep" {
  name                = "pep-${local.container_registry_name}"
  resource_group_name = var.virtual_network_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "pep-${local.container_registry_name}"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "pep-${local.container_registry_name}"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.acr_dns_zone.id
    ]
  }

  tags = var.default_tags
}

resource "azurerm_private_dns_zone" "acr_dns_zone" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.virtual_network_resource_group_name

  tags = var.default_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr_dns_link" {
  name                  = "privatelink.azurecr.io-link"
  resource_group_name   = var.virtual_network_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.acr_dns_zone.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false

  tags = var.default_tags
}