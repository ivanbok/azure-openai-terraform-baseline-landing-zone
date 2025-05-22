# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

# -- AI Project AVM Module --
# Ref: https://registry.terraform.io/modules/Azure/avm-res-machinelearningservices-workspace/azurerm/latest
module "project" {
  source  = "Azure/avm-res-machinelearningservices-workspace/azurerm"
  version = "0.6.0" # "0.4.1"

  name                = local.project.name
  location            = var.location
  resource_group_name = var.resource_group_name

  kind = "Project"

  workspace_friendly_name = local.project.workspace_friendly_name
  workspace_description   = local.project.workspace_description

  ai_studio_hub_id = var.ai_hub_resource_id

  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = []
  }

  storage_access_type = "identity"
  storage_account = {
    create_new  = false
    resource_id = var.ai_foundry_storage_account_id
  }

  key_vault = {
    create_new  = false
    resource_id = var.key_vault_id
  }

  is_private = false # Set to false for testing
  workspace_managed_network = {
    isolation_mode = "Disabled"
    spark_ready    = true
  }

  tags = var.default_tags
}

# There is currently no way to use azurerm provider to create an online endpoint. We therefore need to use azapi
# https://learn.microsoft.com/en-us/answers/questions/1168249/create-a-managed-ml-inference-endpoint-and-deploym
resource "azapi_resource" "ml_online_endpoint" {
  depends_on = [module.project]
  type       = "Microsoft.MachineLearningServices/workspaces/onlineEndpoints@2025-01-01-preview"
  name       = "ept-${local.project.name}"
  location   = var.location
  parent_id  = module.project.resource_id

  identity {
    type = "SystemAssigned"
  }

  body = {
    properties = {
      description         = "This is the /score endpoint for the prompt flow deployment"
      authMode            = "Key"     # May consider using RBAC instead of Key Auth
      publicNetworkAccess = "Enabled" # Temporarily Enabled for testing
    }
    kind = "Managed"
  }

  lifecycle {
    ignore_changes = [
      body["properties"]["provisioningState"],
      body["properties"]["scoringUri"],
      body["properties"]["swaggerUri"],
      body["properties"]["AzureAsyncOperationUri"]
    ]
  }
}

# -- Role Assignments for Project (for usage of Agent Service) -- #
resource "azurerm_role_assignment" "workspace_azure_ai_developer" {
  scope              = var.openai_resource_id
  role_definition_id = local.azure_ai_developer_id
  principal_id       = module.project.workspace_identity.principal_id
  principal_type     = "ServicePrincipal"
}

# -- Role Assignments for Endpoint -- #
resource "azurerm_role_assignment" "endpoint_secret_reader" {
  scope              = module.project.resource_id
  role_definition_id = local.aml_workspace_secrets_reader_role_id
  principal_id       = azapi_resource.ml_online_endpoint.output.identity.principalId
  principal_type     = "ServicePrincipal"
}

# Assignments for OpenAI Cognitive Services
resource "azurerm_role_assignment" "endpoint_openai_user" {
  scope              = var.openai_resource_id
  role_definition_id = local.cognitive_services_openai_user_id
  principal_id       = azapi_resource.ml_online_endpoint.output.identity.principalId
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "endpoint_openai_contributor" {
  scope              = var.openai_resource_id
  role_definition_id = local.cognitive_services_openai_contributor_id
  principal_id       = azapi_resource.ml_online_endpoint.output.identity.principalId
  principal_type     = "ServicePrincipal"
}

# Assignments for AI Search
resource "azurerm_role_assignment" "endpoint_search_index_data_contributor" {
  count              = var.provision_ai_search ? 1 : 0
  scope              = var.ai_search_resource_id
  role_definition_id = local.search_index_data_contributor_id
  principal_id       = azapi_resource.ml_online_endpoint.output.identity.principalId
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "endpoint_search_index_data_reader" {
  count              = var.provision_ai_search ? 1 : 0
  scope              = var.ai_search_resource_id
  role_definition_id = local.search_index_data_reader_id
  principal_id       = azapi_resource.ml_online_endpoint.output.identity.principalId
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "endpoint_search_service_contributor" {
  count              = var.provision_ai_search ? 1 : 0
  scope              = var.ai_search_resource_id
  role_definition_id = local.search_service_contributor_id
  principal_id       = azapi_resource.ml_online_endpoint.output.identity.principalId
  principal_type     = "ServicePrincipal"
}

# Assignments for Storage Account
resource "azurerm_role_assignment" "endpoint_blob_data_contributor" {
  scope              = var.ai_foundry_storage_account_id
  role_definition_id = local.storage_blob_data_contributor_id
  principal_id       = azapi_resource.ml_online_endpoint.output.identity.principalId
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "endpoint_file_data_contributor" {
  scope              = var.ai_foundry_storage_account_id
  role_definition_id = local.storage_file_data_contributor_id
  principal_id       = azapi_resource.ml_online_endpoint.output.identity.principalId
  principal_type     = "ServicePrincipal"
}

# -- Diagnostic Settings -- #
resource "azurerm_monitor_diagnostic_setting" "project" {
  name                       = "default"
  target_resource_id         = module.project.resource_id
  log_analytics_workspace_id = var.log_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
  lifecycle {
    ignore_changes = [
      metric
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "endpoint" {
  name                       = "default"
  target_resource_id         = azapi_resource.ml_online_endpoint.id
  log_analytics_workspace_id = var.log_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
  lifecycle {
    ignore_changes = [
      metric
    ]
  }
}