variable "base_name" {
  description = "This is the base name for each Azure resource name"
  type        = string
}

variable "location" {
  description = "The resource group location"
  type        = string
}

variable "openai_location" {
  description = "The location of the OpenAI deployment. This may be be outside of Southeast Asia as S0 is currently not supported"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the resources will be created."
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

variable "openai_models" {
  description = "The models to be deployed in the OpenAI resource."
  type        = list(string)

  validation {
    condition     = alltrue([for model in var.openai_models : contains(keys(var.openai_version_map), model)])
    error_message = "All models must exist in the version map."
  }
}

variable "openai_version_map" {
  description = "Map of OpenAI models to their versions."
  type        = map(string)
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

variable "azureml_service_tag_ip_ranges" {
  description = "IP ranges for Azure Machine Learning Service (required to use Agent Service Integration)."
  type        = list(string)
}

variable "default_tags" {
  description = "Default tags to be applied to all resources."
  type        = map(string)
}