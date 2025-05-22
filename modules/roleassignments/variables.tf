variable "principal_id" {
  description = "The principal ID of the user or principal to assign roles to."
  type        = string
}

variable "app_deploy_storage_id" {
  description = "The name of the storage account used for app deployments."
  type        = string

  validation {
    condition = can(regex(
      "^/subscriptions/[0-9a-fA-F-]+/resourceGroups/[^/]+/providers/Microsoft\\.Storage/storageAccounts/[^/]+$",
      var.app_deploy_storage_id
    ))
    error_message = <<EOT
    The app_deploy_storage_id must be a valid Azure Storage Account resource ID in the format of
    /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Storage/storageAccounts/<storage-account-name>
    EOT
  }
}

variable "ml_deploy_storage_id" {
  description = "The name of the storage account used for the ML workspace."
  type        = string

  validation {
    condition = can(regex(
      "^/subscriptions/[0-9a-fA-F-]+/resourceGroups/[^/]+/providers/Microsoft\\.Storage/storageAccounts/[^/]+$",
      var.ml_deploy_storage_id
    ))
    error_message = <<EOT
    The ml_deploy_storage_id must be a valid Azure Storage Account resource ID in the format of
    /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Storage/storageAccounts/<storage-account-name>
    EOT
  }
}

variable "key_vault_id" {
  description = "The resource ID of the Azure Key Vault to use for the workspace."
  type        = string

  validation {
    condition = can(regex(
      "^/subscriptions/[0-9a-fA-F-]+/resourceGroups/[^/]+/providers/Microsoft\\.KeyVault/vaults/[^/]+$",
      var.key_vault_id
    ))
    error_message = <<EOT
    The key_vault_id must be a valid Azure Key Vault resource ID in the format of
    /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.KeyVault/vaults/<vault-name>
    EOT
  }
}

variable "provision_ai_search" {
  description = "Boolean to indicate whether AI search is provisioned."
  type        = bool
}

variable "ai_search_resource_id" {
  description = "The resource ID of the Azure AI Search service to use for the workspace. Leave as empty string if not using AI search."
  type        = string

  validation {
    condition = can(regex(
      "^$|^/subscriptions/[0-9a-fA-F-]+/resourceGroups/[^/]+/providers/Microsoft\\.Search/searchServices/[^/]+$",
      var.ai_search_resource_id
    ))
    error_message = <<EOT
    The ai_search_resource_id must be either empty or a valid Azure AI Search resource ID in the format:
    /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Search/searchServices/<search-service-name>

    If not using AI search, this variable can be left as an empty string.
    EOT
  }
}

variable "openai_resource_id" {
  description = "The resource ID of the Azure OpenAI (Cognitive Services) Account to use for the workspace."
  type        = string

  validation {
    condition = can(regex(
      "^/subscriptions/[0-9a-fA-F-]+/resourceGroups/[^/]+/providers/Microsoft\\.CognitiveServices/accounts/[^/]+$",
      var.openai_resource_id
    ))
    error_message = <<EOT
    The openai_resource_id must be a valid Azure OpenAI (Cognitive Services) Account resource ID in the format of
    /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.CognitiveServices/accounts/<openai-account-name>
    EOT
  }
}
