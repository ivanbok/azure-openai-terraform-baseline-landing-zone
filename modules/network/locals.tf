# ------------------ LOCALS ------------------
locals {
  app_gateway_subnet_name         = "snet-appGateway"
  app_service_subnet_name         = "snet-appServicePlan"
  private_endpoints_subnet_name   = "snet-privateEndpoints"
  agents_subnet_name              = "snet-agents"
  jumpbox_subnet_name             = "snet-jumpbox"

  nsg_app_gateway_name            = "nsg-appGatewaySubnet"
  nsg_app_services_name           = "nsg-appServicesSubnet"
  nsg_private_endpoints_name      = "nsg-privateEndpointsSubnet"
  nsg_agents_name                 = "nsg-agentsSubnet"
  nsg_jumpbox_name                = "nsg-jumpboxSubnet"
}

# Function to get UDR ID
locals {
  internet_udr_id = var.existing_udr_for_internet_traffic_name != "" ? data.azurerm_route_table.internet_udr[0].id : null
}