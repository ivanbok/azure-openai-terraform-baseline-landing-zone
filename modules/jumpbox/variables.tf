variable "base_name" {
  description = "This is the base name for each Azure resource name"
  type        = string

  validation {
    condition     = length(var.base_name) >= 4 && length(var.base_name) <= 12
    error_message = "Base name must be between 4 and 12 characters."
  }
}

variable "location" {
  description = "The region in which this architecture is deployed."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group that all resources will be deployed into."
  type        = string
}

variable "virtual_network_resource_group_name" {
  description = "The name of the resource group that contains the virtual network."
  type        = string
}

variable "jumpbox_subnet_id" {
  description = "The ID of the subnet for the jump box."
  type        = string

  validation {
    condition = can(regex(
      "^/subscriptions/[0-9a-fA-F-]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+/subnets/[^/]+$",
      var.jumpbox_subnet_id
    ))
    error_message = <<EOT
    The jumpbox_subnet_id must be a valid Azure subnet resource ID in the format of
    /subscriptions/<subscription-id>/resourceGroups/<vnet-resource-group>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<subnet-name>
    EOT
  }
}

variable "jump_box_admin_name" {
  description = "Name of the administrator account."
  type        = string
  default     = "vmadmin"
}

variable "log_workspace_name" {
  description = "Name of the Log Analytics workspace."
  type        = string
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

variable "default_tags" {
  description = "Default tags to be applied to all resources."
  type        = map(string)
}