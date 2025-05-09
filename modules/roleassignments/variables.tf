variable "your_principal_id" {
  description = "The principal ID of the user to assign roles to."
  type        = string
}

variable "app_deploy_storage_id" {
  description = "The name of the storage account used for app deployments."
  type        = string
}

variable "ml_deploy_storage_id" {
  description = "The name of the storage account used for the ML workspace."
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the Key Vault to use for the workspace."
  type        = string
}

variable "provision_ai_search" {
  description = "Boolean to indicate whether AI search is provisioned."
  type        = bool
}

variable "ai_search_resource_id" {
  description = "The ID of the AI Search resource to use for the workspace."
  type        = string
}

variable "openai_resource_id" {
  description = "The ID of the OpenAI Cognitive Services Account to use for the workspace."
  type        = string
}

