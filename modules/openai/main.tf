resource "azurerm_cognitive_account" "openai" {
  name                = local.openai_name
  location            = var.openai_location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = "S0"
  custom_subdomain_name = "oai${var.base_name}"

  network_acls {
    default_action = length(var.ingress_client_ip) > 0 ? "Deny" : "Allow"
    ip_rules       = var.ingress_client_ip
  }

  public_network_access_enabled      = true
  local_auth_enabled                 = true
  outbound_network_access_restricted = true
  tags = {}
}

resource "azurerm_cognitive_deployment" "openai_deployments" {
  for_each = toset(var.openai_models)

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
  name                = local.openai_private_endpoint
  location            = var.location
  resource_group_name = var.virtual_network_resource_group_name

  subnet_id = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = local.openai_private_endpoint
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  depends_on = [
    azurerm_cognitive_account.openai,
    azurerm_cognitive_deployment.openai_deployments
  ]
}