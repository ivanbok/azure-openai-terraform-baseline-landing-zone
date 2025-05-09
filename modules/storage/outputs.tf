# Outputs
output "app_deploy_storage_name" {
  value = azurerm_storage_account.app.name
}

output "app_deploy_storage_id" {
  value = azurerm_storage_account.app.id
}

output "app_deploy_storage_primary_blob_endpoint" {
  value = azurerm_storage_account.app.primary_blob_endpoint
}

output "ml_deploy_storage_name" {
  value = azurerm_storage_account.ml.name
}

output "ml_deploy_storage_id" {
  value = azurerm_storage_account.ml.id
}