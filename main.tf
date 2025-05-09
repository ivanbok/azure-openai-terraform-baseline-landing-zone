# -------- Data Sources -------- #
data "azurerm_resource_group" "workload" {
  name = var.workload_resource_group_name
}

data "azurerm_resource_group" "spoke" {
  name = local.spoke_rg_name
}

# ----------- Modules ---------- #
module "monitoring" {
  source              = "./modules/monitoring"
  base_name           = var.base_name
  location            = data.azurerm_resource_group.workload.location
  resource_group_name = data.azurerm_resource_group.workload.name
}

module "network" {
  source                                 = "./modules/network"
  location                               = data.azurerm_resource_group.spoke.location
  vnet_name                              = local.spoke_vnet_name
  virtual_network_resource_group_name    = data.azurerm_resource_group.spoke.name
  existing_udr_for_internet_traffic_name = local.udr_name
  bastion_subnet_prefix                  = var.bastion_subnet_prefix
  app_services_subnet_prefix             = var.app_services_subnet_prefix
  app_gateway_subnet_prefix              = var.app_gateway_subnet_prefix
  private_endpoints_subnet_prefix        = var.private_endpoints_subnet_prefix
  agents_subnet_prefix                   = var.agents_subnet_prefix
  jumpbox_subnet_prefix                  = var.jumpbox_subnet_prefix
}

module "storage" {
  source                              = "./modules/storage"
  base_name                           = var.base_name
  location                            = data.azurerm_resource_group.workload.location
  resource_group_name                 = data.azurerm_resource_group.workload.name
  virtual_network_resource_group_name = data.azurerm_resource_group.spoke.name
  private_endpoints_subnet_id         = module.network.private_endpoints_subnet_id
  log_workspace_id                    = module.monitoring.log_workspace_id
  ingress_client_ip                   = var.ingress_client_ip
}

module "keyvault" {
  source                              = "./modules/keyvault"
  base_name                           = var.base_name
  location                            = data.azurerm_resource_group.workload.location
  resource_group_name                 = data.azurerm_resource_group.workload.name
  vnet_id                             = var.existing_resource_id_for_spoke_vnet
  virtual_network_resource_group_name = data.azurerm_resource_group.spoke.name
  private_endpoints_subnet_id         = module.network.private_endpoints_subnet_id
  log_workspace_id                    = module.monitoring.log_workspace_id
  ingress_client_ip                   = var.ingress_client_ip
}

module "acr" {
  source                              = "./modules/acr"
  base_name                           = var.base_name
  location                            = data.azurerm_resource_group.workload.location
  resource_group_name                 = data.azurerm_resource_group.workload.name
  virtual_network_resource_group_name = data.azurerm_resource_group.spoke.name
  private_endpoints_subnet_id         = module.network.private_endpoints_subnet_id
  build_agent_subnet_id               = module.network.agent_subnet_id
  log_workspace_id                    = module.monitoring.log_workspace_id
  ingress_client_ip                   = var.ingress_client_ip
}

module "openai" {
  source                              = "./modules/openai"
  base_name                           = var.base_name
  location                            = data.azurerm_resource_group.workload.location
  openai_location                     = var.openai_location
  resource_group_name                 = data.azurerm_resource_group.workload.name
  virtual_network_resource_group_name = data.azurerm_resource_group.spoke.name
  openai_models                       = var.openai_models
  openai_version_map                  = var.openai_version_map
  private_endpoints_subnet_id         = module.network.private_endpoints_subnet_id
  log_workspace_id                    = module.monitoring.log_workspace_id
  ingress_client_ip                   = var.ingress_client_ip
}

module "aisearch" {
  source                              = "./modules/aisearch"
  count                               = var.provision_ai_search ? 1 : 0
  base_name                           = var.base_name
  location                            = data.azurerm_resource_group.workload.location
  resource_group_name                 = data.azurerm_resource_group.workload.name
  virtual_network_resource_group_name = data.azurerm_resource_group.spoke.name
  vnet_id                             = var.existing_resource_id_for_spoke_vnet
  private_endpoints_subnet_id         = module.network.private_endpoints_subnet_id
  log_workspace_id                    = module.monitoring.log_workspace_id
  telemetry_opt_out                   = var.telemetry_opt_out
  ingress_client_ip                   = var.ingress_client_ip
}

module "aifoundryhub" {
  depends_on                          = [module.openai]
  source                              = "./modules/aifoundryhub"
  base_name                           = var.base_name
  location                            = data.azurerm_resource_group.workload.location
  resource_group_name                 = data.azurerm_resource_group.workload.name
  virtual_network_resource_group_name = data.azurerm_resource_group.spoke.name
  private_endpoints_subnet_id         = module.network.private_endpoints_subnet_id
  appinsights_id                      = module.monitoring.application_insights_id
  key_vault_id                        = module.keyvault.key_vault_id
  ai_foundry_storage_account_id       = module.storage.ml_deploy_storage_id
  container_registry_id               = module.acr.acr_id
  log_workspace_id                    = module.monitoring.log_workspace_id
  openai_resource_name                = module.openai.openai_resource_name
  openai_resource_id                  = module.openai.openai_resource_id
  openai_endpoint                     = module.openai.openai_endpoint
  provision_ai_search                 = var.provision_ai_search
  ai_search_resource_id               = var.provision_ai_search ? module.aisearch[0].ai_search_resource_id : ""
  ai_search_resource_name             = var.provision_ai_search ? module.aisearch[0].ai_search_resource_name : ""
  ingress_client_ip                   = var.ingress_client_ip
}

# Multiple of these can be provisioned
module "aiproject" {
  depends_on                          = [ module.aifoundryhub ]
  source                              = "./modules/aiproject"
  count                               = 2 # For Testing of multi-projects. In practice, we will create them on-demand
  location                            = data.azurerm_resource_group.workload.location
  resource_group_name                 = data.azurerm_resource_group.workload.name
  ai_hub_resource_id                  = module.aifoundryhub.ai_hub_resource_id
  ai_foundry_storage_account_id       = module.storage.ml_deploy_storage_id
  log_workspace_id                    = module.monitoring.log_workspace_id
  openai_resource_id                  = module.openai.openai_resource_id
  provision_ai_search                 = var.provision_ai_search
  ai_search_resource_id               = var.provision_ai_search ? module.aisearch[0].ai_search_resource_id : ""
}

module "jumpbox" {
  source                              = "./modules/jumpbox"
  base_name                           = var.base_name
  location                            = data.azurerm_resource_group.workload.location
  resource_group_name                 = data.azurerm_resource_group.workload.name
  jump_box_admin_name                 = var.jump_box_admin_name
  jump_box_admin_password             = var.jump_box_admin_password
  virtual_network_resource_group_name = data.azurerm_resource_group.spoke.name
  jumpbox_subnet_id                   = module.network.jumpbox_subnet_id
  log_workspace_name                  = module.monitoring.log_workspace_name
  log_workspace_id                    = module.monitoring.log_workspace_id
}

# Multiple of these can be provisioned for each User principal assigned to the subscription
module "roleassignments" {
  for_each                            = zipmap(var.user_principal_ids, var.user_principal_ids)
  source                              = "./modules/roleassignments"
  your_principal_id                   = each.value
  app_deploy_storage_id               = module.storage.app_deploy_storage_id
  ml_deploy_storage_id                = module.storage.ml_deploy_storage_id
  key_vault_id                        = module.keyvault.key_vault_id
  provision_ai_search                 = var.provision_ai_search
  ai_search_resource_id               = var.provision_ai_search ? module.aisearch[0].ai_search_resource_id : ""
  openai_resource_id                  = module.openai.openai_resource_id
}