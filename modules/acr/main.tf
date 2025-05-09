# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                          = "cr${var.base_name}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = true
  zone_redundancy_enabled       = true

  network_rule_set {
    default_action = length(var.ingress_client_ip) > 0 ? "Deny" : "Allow"
    ip_rule = concat(
      [
        for ip in var.ingress_client_ip : {
          ip_range = "${ip}/32"
          action   = "Allow"
        }
      ]
    )
  }

  data_endpoint_enabled = false

  export_policy_enabled = true # set to true for deployment, false once completed
  trust_policy_enabled  = false
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

# Private endpoint for ACR
resource "azurerm_private_endpoint" "acr_pep" {
  name                = "pep-cr${var.base_name}"
  resource_group_name = var.virtual_network_resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "pep-cr${var.base_name}"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
}