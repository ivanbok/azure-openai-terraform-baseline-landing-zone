data "http" "my_ip" {
  url = "https://api.ipify.org"
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
  suffix  = [var.base_name]
}

# Generate a random suffix for the OpenAI Subdomain
resource "random_string" "suffix" {
  length  = 4
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "azurerm_cognitive_account" "openai" {
  name                  = local.openai_name
  location              = var.openai_location
  resource_group_name   = var.resource_group_name
  kind                  = "OpenAI"
  sku_name              = "S0"
  custom_subdomain_name = "oai${var.base_name}${random_string.suffix.result}"

  network_acls {
    default_action = "Deny"
    ip_rules       = concat([local.my_ip], var.ingress_client_ip, var.azureml_service_tag_ip_ranges)
  }

  public_network_access_enabled      = true
  local_auth_enabled                 = true
  outbound_network_access_restricted = true
  tags                               = var.default_tags
}

resource "azurerm_cognitive_deployment" "openai_deployments" {
  for_each             = toset(var.openai_models)
  name                 = each.key
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = each.key
    version = var.openai_version_map[each.key]
  }

  sku {
    name     = "Standard"
    capacity = 25
  }

  version_upgrade_option = "NoAutoUpgrade"
}

resource "azurerm_monitor_diagnostic_setting" "openai_diag" {
  name                       = "default"
  target_resource_id         = azurerm_cognitive_account.openai.id
  log_analytics_workspace_id = var.log_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
}

resource "azurerm_private_endpoint" "openai_pe" {
  depends_on = [
    azurerm_cognitive_account.openai,
    azurerm_cognitive_deployment.openai_deployments
  ]

  name                = "pep-${local.openai_name}"
  location            = var.location
  resource_group_name = var.virtual_network_resource_group_name

  subnet_id = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = "pep-${local.openai_name}"
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "pep-${local.openai_name}"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.openai_dns_zone.id,
    ]
  }
  tags = var.default_tags
}

resource "azurerm_private_dns_zone" "openai_dns_zone" {
  name                = "privatelink.openai.azure.com"
  resource_group_name = var.virtual_network_resource_group_name
  tags                = var.default_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "openai_dns_link" {
  name                  = "privatelink.openai.azure.com-link"
  resource_group_name   = var.virtual_network_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.openai_dns_zone.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
  tags                  = var.default_tags
}
