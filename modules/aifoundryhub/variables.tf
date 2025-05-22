variable "base_name" {
  description = "This is the base name for each Azure resource name"
  type        = string

  validation {
    condition     = length(var.base_name) >= 4 && length(var.base_name) <= 12
    error_message = "Base name must be between 4 and 12 characters."
  }
}

variable "location" {
  description = "The resource group location"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to create the Foundry Hub and Workspace in."
  type        = string
}

variable "vnet_id" {
  description = "The Resource ID of the spoke virtual network."
  type        = string

  validation {
    condition = can(regex(
      "^/subscriptions/[0-9a-fA-F-]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+$",
      var.vnet_id
    ))
    error_message = <<EOT
    The value must be a valid Azure Virtual Network resource ID in the format of 
    /subscriptions/<subscription-id>/resourceGroups/<vnet-resource-group>/providers/Microsoft.Network/virtualNetworks/<vnet-name>
    EOT
  }
}

variable "virtual_network_resource_group_name" {
  description = "The name of the resource group containing the spoke virtual network."
  type        = string
}

variable "private_endpoints_subnet_id" {
  description = "The resource ID of the subnet used for private endpoints."
  type        = string

  validation {
    condition = can(regex(
      "^/subscriptions/[0-9a-fA-F-]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+/subnets/[^/]+$",
      var.private_endpoints_subnet_id
    ))
    error_message = <<EOT
    The private_endpoints_subnet_id must be a valid Azure subnet resource ID in the format of
    /subscriptions/<subscription-id>/resourceGroups/<vnet-resource-group>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<subnet-name>
    EOT
  }
}

variable "appinsights_id" {
  description = "The resource ID of the Application Insights resource to use for the workspace."
  type        = string

  validation {
    condition = can(
      regex("^/subscriptions/[0-9a-fA-F-]+/resourceGroups/[^/]+/providers/Microsoft\\.Insights/components/[^/]+$",
        var.appinsights_id
    ))
    error_message = <<EOT
    The appinsights_id must be a valid Azure Application Insights resource ID in the format of
    /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Insights/components/<appinsights-name>
    EOT
  }
}

variable "container_registry_id" {
  description = "The resource ID of the Azure Container Registry to use for the workspace."
  type        = string

  validation {
    condition = can(regex(
      "^/subscriptions/[0-9a-fA-F-]+/resourceGroups/[^/]+/providers/Microsoft\\.ContainerRegistry/registries/[^/]+$",
      var.container_registry_id
    ))
    error_message = <<EOT
    The container_registry_id must be a valid Azure Container Registry resource ID in the format of
    /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.ContainerRegistry/registries/<registry-name>
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

variable "ai_foundry_storage_account_id" {
  description = "The resource ID of the Azure Storage Account to use for the workspace."
  type        = string

  validation {
    condition = can(regex(
      "^/subscriptions/[0-9a-fA-F-]+/resourceGroups/[^/]+/providers/Microsoft\\.Storage/storageAccounts/[^/]+$",
      var.ai_foundry_storage_account_id
    ))
    error_message = <<EOT
    The ai_foundry_storage_account_id must be a valid Azure Storage Account resource ID in the format of
    /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Storage/storageAccounts/<storage-account-name>
    EOT
  }
}

variable "log_workspace_id" {
  description = "The resource ID of an existing Log Analytics workspace."
  type        = string

  validation {
    condition = can(regex(
      "^/subscriptions/[0-9a-fA-F-]+/resourceGroups/[^/]+/providers/Microsoft\\.OperationalInsights/workspaces/[^/]+$",
      var.log_workspace_id
    ))
    error_message = <<EOT
    The log_workspace_id must be a valid Azure Log Analytics Workspace resource ID in the format of
    /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.OperationalInsights/workspaces/<workspace-name>
    EOT
  }
}

variable "openai_resource_name" {
  description = "The ID of the OpenAI Cognitive Services Account to use for the workspace."
  type        = string
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

variable "openai_endpoint" {
  description = "The endpoint of the Azure OpenAI (Cognitive Services) Account to use for the workspace."
  type        = string

  validation {
    condition     = can(regex("^https://[a-zA-Z0-9-]+\\.openai\\.azure\\.com/?$", var.openai_endpoint))
    error_message = <<EOT
    The openai_endpoint must be a valid Azure OpenAI endpoint URL in the format of
    https://<resource-name>.openai.azure.com/
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

variable "ai_search_resource_name" {
  description = "The name of the AI Search resource."
  type        = string
}

variable "ingress_client_ip" {
  description = "Allowlist for Ingress IPs (e.g. your corporate network public IPs)."
  type        = list(string)

  validation {
    condition = alltrue([
      for ip in var.ingress_client_ip :
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))
    ])
    error_message = "Each item in ingress_client_ip must be a valid IPv4 address."
  }
}

variable "default_tags" {
  description = "Default tags to be applied to all resources."
  type        = map(string)
}