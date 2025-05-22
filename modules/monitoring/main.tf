module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
  suffix  = [var.base_name]
}

resource "azurerm_log_analytics_workspace" "log" {
  name                = module.naming.log_analytics_workspace.name_unique
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  internet_ingestion_enabled = true
  internet_query_enabled     = true
  tags                       = var.default_tags
}

resource "azurerm_application_insights" "appi" {
  name                = module.naming.application_insights.name_unique
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.log.id
  retention_in_days   = 90

  internet_ingestion_enabled = true
  internet_query_enabled     = true
  tags                       = var.default_tags
}
