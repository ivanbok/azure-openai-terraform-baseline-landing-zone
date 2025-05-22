data "http" "my_ip" {
  url = "https://api.ipify.org"
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
  suffix  = [var.base_name]
}

# AI Search AVM Module
# https://registry.terraform.io/modules/Azure/avm-res-search-searchservice/azurerm/latest
module "search_service" {
  source  = "Azure/avm-res-search-searchservice/azurerm"
  version = "0.1.5"

  location            = var.location
  resource_group_name = var.resource_group_name
  name                = local.search_service_name

  sku                           = "standard"
  semantic_search_sku           = "free"
  public_network_access_enabled = true

  # Allow access only from SEED IPs
  allowed_ips = concat([local.my_ip], var.ingress_client_ip)

  local_authentication_enabled = false # Force usage of Entra ID
  managed_identities = {
    system_assigned = true
  }
  enable_telemetry = !var.telemetry_opt_out

  private_endpoints = {
    ai_search_pe = {
      private_dns_zone_resource_ids = [azurerm_private_dns_zone.ai_search_dns_zone.id]
      private_dns_zone_name         = azurerm_private_dns_zone.ai_search_dns_zone.name
      subnet_resource_id            = var.private_endpoints_subnet_id
      resource_group_name           = var.virtual_network_resource_group_name
    }
  }

  tags = var.default_tags
}

resource "azurerm_private_dns_zone" "ai_search_dns_zone" {
  name                = "privatelink.aisearch.windows.net"
  resource_group_name = var.virtual_network_resource_group_name
  tags                = var.default_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "ai_search_dns_link" {
  name                  = "privatelink.aisearch.windows.net-link"
  private_dns_zone_name = azurerm_private_dns_zone.ai_search_dns_zone.name
  resource_group_name   = var.virtual_network_resource_group_name
  virtual_network_id    = var.vnet_id
  tags                  = var.default_tags
}

resource "azurerm_private_dns_a_record" "ai_search_dns_a_record" {
  for_each = module.search_service.private_endpoints

  name                = module.search_service.resource.name
  records             = [each.value.private_service_connection[0].private_ip_address]
  resource_group_name = var.virtual_network_resource_group_name
  ttl                 = 300
  zone_name           = azurerm_private_dns_zone.ai_search_dns_zone.name
  tags                = var.default_tags
}

resource "azurerm_monitor_diagnostic_setting" "search_service" {
  name                       = "default"
  target_resource_id         = module.search_service.resource_id
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