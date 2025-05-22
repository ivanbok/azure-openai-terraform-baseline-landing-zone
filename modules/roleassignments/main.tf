# --- Key Vault Role Assignments --- #

resource "azurerm_role_assignment" "key_vault_administrator" {
  scope              = var.key_vault_id
  role_definition_id = local.key_vault_administrator_id
  principal_id       = var.principal_id
}

# --- Storage Account Role Assignments --- #

resource "azurerm_role_assignment" "blob_contributor" {
  scope              = var.app_deploy_storage_id
  role_definition_id = local.storage_blob_data_contributor_id
  principal_id       = var.principal_id
}

resource "azurerm_role_assignment" "blob_data_contributor" {
  scope              = var.ml_deploy_storage_id
  role_definition_id = local.storage_blob_data_contributor_id
  principal_id       = var.principal_id
}

resource "azurerm_role_assignment" "file_data_contributor" {
  scope              = var.ml_deploy_storage_id
  role_definition_id = local.storage_file_data_contributor_id
  principal_id       = var.principal_id
}

# --- Azure OpenAI Role Assignments --- #

resource "azurerm_role_assignment" "openai_user" {
  scope              = var.openai_resource_id
  role_definition_id = local.cognitive_services_openai_user_id
  principal_id       = var.principal_id
}

resource "azurerm_role_assignment" "openai_contributor" {
  scope              = var.openai_resource_id
  role_definition_id = local.cognitive_services_openai_contributor_id
  principal_id       = var.principal_id
}

# --- Azure AI Search Role Assignments --- #

resource "azurerm_role_assignment" "search_index_data_contributor" {
  count              = var.provision_ai_search ? 1 : 0
  scope              = var.ai_search_resource_id
  role_definition_id = local.search_index_data_contributor_id
  principal_id       = var.principal_id
}

resource "azurerm_role_assignment" "search_index_data_reader" {
  count              = var.provision_ai_search ? 1 : 0
  scope              = var.ai_search_resource_id
  role_definition_id = local.search_index_data_reader_id
  principal_id       = var.principal_id
}