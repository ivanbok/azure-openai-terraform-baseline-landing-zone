variable "subscription_id" {
  description = "The subscription ID where the resources will be deployed."
  type        = string
}

variable "workload_resource_group_name" {
  description = "Name of the resource group that all resources (except networking components) will be deployed into."
  type        = string
}

variable "base_name" {
  description = "This is the base name for each Azure resource name (4-12 chars)"
  type        = string

  validation {
    condition     = length(var.base_name) >= 4 && length(var.base_name) <= 12
    error_message = "Base name must be between 4 and 12 characters."
  }
}

variable "openai_location" {
  description = "The location of the OpenAI deployment. This is to overcome regional limitations of Azure OpenAI."
  type        = string
  default     = "eastus2"
}

variable "openai_models" {
  description = "The models to be deployed in the OpenAI resource."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for model in var.openai_models : contains(keys(var.openai_version_map), model)])
    error_message = "All models must exist in the version map."
  }
}

variable "openai_version_map" {
  type = map(string)
  default = {
    "o1"           = "2024-12-17"
    "gpt-35-turbo" = "0125"
    "gpt-4o"       = "2024-11-20"
    "gpt-4o-mini"  = "2024-07-18"
    "o3-mini"      = "2025-01-31"
  }
}

variable "provision_ai_search" {
  description = "Set to true to provision AI Search."
  type        = bool
  default     = true
}

variable "existing_resource_id_for_spoke_vnet" {
  description = "The resource ID of the existing VNet"
  type        = string

  validation {
    condition = can(regex(
      "^/subscriptions/[0-9a-fA-F-]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+$",
      var.existing_resource_id_for_spoke_vnet
    ))
    error_message = <<EOT
    The value must be a valid Azure Virtual Network resource ID in the format of 
    /subscriptions/<subscription-id>/resourceGroups/<vnet-resource-group>/providers/Microsoft.Network/virtualNetworks/<vnet-name>
    EOT
  }
}

variable "existing_resource_id_for_udr" {
  description = "The resource ID of the existing User Defined Route (UDR). Optional, provide an empty string if not using UDR."
  type        = string

  validation {
    condition = can(regex(
      "^$|^/subscriptions/[0-9a-fA-F-]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/routeTables/[^/]+$",
      var.existing_resource_id_for_udr
    ))
    error_message = <<EOT
    The value must be either empty or a valid Azure Route Table resource ID in the format:
    /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/routeTables/<route-table-name>

    If not using UDR, this variable can be left as an empty string.
    EOT
  }
}

# This is to allow ingress from specific IPs, such as your corporate network public IPs
variable "ingress_client_ip" {
  description = "Allowlist for Ingress IPs (e.g. your corporate network public IPs)."
  type        = list(string)
  default = []

  validation {
    condition = alltrue([
      for ip in var.ingress_client_ip :
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))
    ])
    error_message = "Each item in ingress_client_ip must be a valid IPv4 address."
  }
}

variable "bastion_subnet_prefix" {
  description = "CIDR prefix for the bastion (jumpbox) subnet."
  type        = string

  validation {
    condition = can(regex(
      "^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$",
      var.bastion_subnet_prefix
    ))
    error_message = "The value must be a valid IPv4 CIDR block (e.g., 192.168.1.0/24)."
  }
}

variable "app_services_subnet_prefix" {
  description = "CIDR prefix for the app services subnet."
  type        = string

  validation {
    condition = can(regex(
      "^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$",
      var.app_services_subnet_prefix
    ))
    error_message = "The value must be a valid IPv4 CIDR block (e.g., 192.168.1.0/24)."
  }
}

variable "private_endpoints_subnet_prefix" {
  description = "CIDR prefix for the private endpoints subnet."
  type        = string

  validation {
    condition = can(regex(
      "^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$",
      var.private_endpoints_subnet_prefix
    ))
    error_message = "The value must be a valid IPv4 CIDR block (e.g., 192.168.1.0/24)."
  }
}

variable "agents_subnet_prefix" {
  description = "CIDR prefix for the agents subnet."
  type        = string

  validation {
    condition = can(regex(
      "^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$",
      var.agents_subnet_prefix
    ))
    error_message = "The value must be a valid IPv4 CIDR block (e.g., 192.168.1.0/24)."
  }
}

variable "jumpbox_subnet_prefix" {
  description = "CIDR prefix for the jumpbox subnet."
  type        = string

  validation {
    condition = can(regex(
      "^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$",
      var.jumpbox_subnet_prefix
    ))
    error_message = "The value must be a valid IPv4 CIDR block (e.g., 192.168.1.0/24)."
  }
}

variable "telemetry_opt_out" {
  description = "Set to true to opt out of telemetry."
  type        = bool
  default     = false
}

variable "jump_box_admin_name" {
  description = "Name of the administrator account."
  type        = string
  default     = "azureuser"
}

variable "default_tags" {
  description = "Default tags to be applied to all resources."
  type        = map(string)
  default = {
    project    = "gcc-aas"
    created_by = "terraform"
  }
}