# -------- Data Sources -------- #
data "azurerm_client_config" "current" {}

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
  location            = local.location
  resource_group_name = var.workload_resource_group_name
  default_tags        = var.default_tags
}

module "network" {
  source                                 = "./modules/network"
  location                               = data.azurerm_resource_group.spoke.location
  vnet_name                              = local.spoke_vnet_name
  virtual_network_resource_group_name    = data.azurerm_resource_group.spoke.name
  existing_udr_for_internet_traffic_name = local.udr_name
  bastion_subnet_prefix                  = var.bastion_subnet_prefix
  app_services_subnet_prefix             = var.app_services_subnet_prefix
  private_endpoints_subnet_prefix        = var.private_endpoints_subnet_prefix
  agents_subnet_prefix                   = var.agents_subnet_prefix
  jumpbox_subnet_prefix                  = var.jumpbox_subnet_prefix
}

module "storage" {
  source                              = "./modules/storage"
  base_name                           = var.base_name
  location                            = local.location
  resource_group_name                 = var.workload_resource_group_name
  vnet_id                             = var.existing_resource_id_for_spoke_vnet
  virtual_network_resource_group_name = data.azurerm_resource_group.spoke.name
  private_endpoints_subnet_id         = module.network.private_endpoints_subnet_id
  log_workspace_id                    = module.monitoring.log_workspace_id
  ingress_client_ip                   = var.ingress_client_ip
  default_tags                        = var.default_tags
}

module "keyvault" {
  source                              = "./modules/keyvault"
  base_name                           = var.base_name
  location                            = local.location
  resource_group_name                 = var.workload_resource_group_name
  vnet_id                             = var.existing_resource_id_for_spoke_vnet
  virtual_network_resource_group_name = data.azurerm_resource_group.spoke.name
  private_endpoints_subnet_id         = module.network.private_endpoints_subnet_id
  log_workspace_id                    = module.monitoring.log_workspace_id
  ingress_client_ip                   = var.ingress_client_ip
  default_tags                        = var.default_tags
}

module "acr" {
  source                              = "./modules/acr"
  base_name                           = var.base_name
  location                            = local.location
  resource_group_name                 = var.workload_resource_group_name
  vnet_id                             = var.existing_resource_id_for_spoke_vnet
  virtual_network_resource_group_name = data.azurerm_resource_group.spoke.name
  private_endpoints_subnet_id         = module.network.private_endpoints_subnet_id
  log_workspace_id                    = module.monitoring.log_workspace_id
  ingress_client_ip                   = var.ingress_client_ip
  default_tags                        = var.default_tags
}

module "openai" {
  source                              = "./modules/openai"
  base_name                           = var.base_name
  location                            = local.location
  openai_location                     = var.openai_location
  resource_group_name                 = var.workload_resource_group_name
  vnet_id                             = var.existing_resource_id_for_spoke_vnet
  virtual_network_resource_group_name = data.azurerm_resource_group.spoke.name
  openai_models                       = var.openai_models
  openai_version_map                  = var.openai_version_map
  private_endpoints_subnet_id         = module.network.private_endpoints_subnet_id
  log_workspace_id                    = module.monitoring.log_workspace_id
  ingress_client_ip                   = var.ingress_client_ip
  azureml_service_tag_ip_ranges       = local.azureml_service_tag_ip_ranges[local.location]
  default_tags                        = var.default_tags
}

module "aisearch" {
  source                              = "./modules/aisearch"
  count                               = var.provision_ai_search ? 1 : 0
  base_name                           = var.base_name
  location                            = local.location
  resource_group_name                 = var.workload_resource_group_name
  virtual_network_resource_group_name = data.azurerm_resource_group.spoke.name
  vnet_id                             = var.existing_resource_id_for_spoke_vnet
  private_endpoints_subnet_id         = module.network.private_endpoints_subnet_id
  log_workspace_id                    = module.monitoring.log_workspace_id
  telemetry_opt_out                   = var.telemetry_opt_out
  ingress_client_ip                   = var.ingress_client_ip
  default_tags                        = var.default_tags
}

module "aifoundryhub" {
  depends_on                          = [module.openai]
  source                              = "./modules/aifoundryhub"
  base_name                           = var.base_name
  location                            = local.location
  resource_group_name                 = var.workload_resource_group_name
  vnet_id                             = var.existing_resource_id_for_spoke_vnet
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
  default_tags                        = var.default_tags
}

# Multiple of these can be provisioned
module "aiproject" {
  depends_on                    = [module.aifoundryhub]
  source                        = "./modules/aiproject"
  count                         = 2 # For Testing of multi-projects. In practice, we will create them on-demand
  location                      = local.location
  resource_group_name           = var.workload_resource_group_name
  ai_hub_resource_id            = module.aifoundryhub.ai_hub_resource_id
  key_vault_id                  = module.keyvault.key_vault_id
  ai_foundry_storage_account_id = module.storage.ml_deploy_storage_id
  log_workspace_id              = module.monitoring.log_workspace_id
  openai_resource_id            = module.openai.openai_resource_id
  provision_ai_search           = var.provision_ai_search
  ai_search_resource_id         = var.provision_ai_search ? module.aisearch[0].ai_search_resource_id : ""
  default_tags                  = var.default_tags
}

module "jumpbox" {
  depends_on                          = [module.keyvault]
  source                              = "./modules/jumpbox"
  base_name                           = var.base_name
  location                            = local.location
  resource_group_name                 = var.workload_resource_group_name
  jump_box_admin_name                 = var.jump_box_admin_name
  virtual_network_resource_group_name = data.azurerm_resource_group.spoke.name
  jumpbox_subnet_id                   = module.network.jumpbox_subnet_id
  log_workspace_name                  = module.monitoring.log_workspace_name
  log_workspace_id                    = module.monitoring.log_workspace_id
  key_vault_id                        = module.keyvault.key_vault_id
  default_tags                        = var.default_tags
}

# This assigns RBAC roles to the Jumpbox VM Managed Identity
module "jumpbox_roleassignments" {
  source                = "./modules/roleassignments"
  principal_id          = module.jumpbox.jumpbox_managed_identity_id
  app_deploy_storage_id = module.storage.app_deploy_storage_id
  ml_deploy_storage_id  = module.storage.ml_deploy_storage_id
  key_vault_id          = module.keyvault.key_vault_id
  provision_ai_search   = var.provision_ai_search
  ai_search_resource_id = var.provision_ai_search ? module.aisearch[0].ai_search_resource_id : ""
  openai_resource_id    = module.openai.openai_resource_id
}

# Multiple of these can be provisioned for each User principal assigned to the subscription
# Demonstrating only for one user principal
# In practice, we will create them on-demand by calling this module
module "roleassignments" {
  source                = "./modules/roleassignments"
  principal_id          = data.azurerm_client_config.current.object_id # Principal ID of the Terraform Client (SPN/User)
  app_deploy_storage_id = module.storage.app_deploy_storage_id
  ml_deploy_storage_id  = module.storage.ml_deploy_storage_id
  key_vault_id          = module.keyvault.key_vault_id
  provision_ai_search   = var.provision_ai_search
  ai_search_resource_id = var.provision_ai_search ? module.aisearch[0].ai_search_resource_id : ""
  openai_resource_id    = module.openai.openai_resource_id
}
