output "log_workspace_name" {
  value = azurerm_log_analytics_workspace.log.name
}

output "log_workspace_id" {
  value = azurerm_log_analytics_workspace.log.id
}

output "application_insights_name" {
  value = azurerm_application_insights.appi.name
}

output "application_insights_id" {
  value = azurerm_application_insights.appi.id
}