output "vnet_name" {
  value = var.vnet_name
}

output "app_services_subnet_name" {
  value = azurerm_subnet.app_services.name
}

output "app_services_subnet_id" {
  value = azurerm_subnet.app_services.id
}

output "private_endpoints_subnet_name" {
  value = azurerm_subnet.private_endpoints.name
}

output "private_endpoints_subnet_id" {
  value = azurerm_subnet.private_endpoints.id
}

output "agent_subnet_name" {
  value = azurerm_subnet.agents.name
}

output "agent_subnet_id" {
  value = azurerm_subnet.agents.id
}

output "jumpbox_subnet_name" {
  value = azurerm_subnet.jumpbox.name
}

output "jumpbox_subnet_id" {
  value = azurerm_subnet.jumpbox.id
}