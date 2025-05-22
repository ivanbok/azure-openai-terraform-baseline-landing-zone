# ------------------ LOCALS ------------------
locals {
  app_services_suffix      = "appServices"
  private_endpoints_suffix = "privateEndpoints"
  agents_suffix            = "agents"
  jumpbox_suffix           = "jumpbox"

}

# Function to get UDR ID
locals {
  internet_udr_id = var.existing_udr_for_internet_traffic_name != "" ? data.azurerm_route_table.internet_udr[0].id : null
}