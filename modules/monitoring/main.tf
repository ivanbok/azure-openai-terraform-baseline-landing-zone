resource "azurerm_log_analytics_workspace" "log" {
  name                = "log-${var.base_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  internet_ingestion_enabled = true
  internet_query_enabled     = true
}

resource "azurerm_application_insights" "appi" {
  name                = "appi-${var.base_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.log.id
  retention_in_days = 90

  internet_ingestion_enabled = true
  internet_query_enabled     = true
}
