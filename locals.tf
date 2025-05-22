locals {
  existing_spoke_vnet_parts = split("/", var.existing_resource_id_for_spoke_vnet)
  spoke_rg_name             = local.existing_spoke_vnet_parts[4]
  spoke_vnet_name           = local.existing_spoke_vnet_parts[8]
  location                  = data.azurerm_resource_group.workload.location

  existing_udr_parts = split("/", var.existing_resource_id_for_udr)
  udr_name           = length(local.existing_udr_parts) > 8 ? local.existing_udr_parts[8] : ""

  # Ingress IP ranges for Azure Machine Learning Service: Required to use Agent Service
  # https://www.microsoft.com/en-us/download/details.aspx?id=56519
  azureml_service_tag_ip_ranges = {
    "southeastasia" = [
      "13.67.8.224/28",
      "20.43.128.112/28",
      "20.195.69.64/28",
      "23.98.82.192/28",
      "40.78.234.128/28",
      "40.90.184.249",
      "52.230.56.136"
    ]
    "eastus" = [
      "20.42.0.240/28",
      "20.62.135.208/28",
      "40.71.11.64/28",
      "40.78.227.32/28",
      "40.79.154.64/28",
      "48.211.42.128/27",
      "48.211.42.160/28",
      "52.255.214.109",
      "52.255.217.127"
    ]
    # Add more regions as needed
  }
}