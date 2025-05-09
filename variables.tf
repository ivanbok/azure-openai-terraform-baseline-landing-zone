variable "subscription_id" {
  description = "The subscription ID where the resources will be deployed."
  type        = string  
}

variable "user_principal_ids" {
  description = "Principal IDs of the Users you want to grant access to AI Foundry Hub in your subscription."
  type        = list(string)
}

variable "workload_resource_group_name" {
  description = "Name of the resource group that all resources (except networking components) will be deployed into."
  type        = string
}

variable "base_name" {
  description = "This is the base name for each Azure resource name (6-12 chars)"
  type        = string
  validation {
    condition     = length(var.base_name) >= 6 && length(var.base_name) <= 12
    error_message = "Base name must be between 6 and 12 characters."
  }
}

variable "openai_location" {
  description = "The location of the OpenAI deployment. This may be be in a different region than the rest of the resources due to model support."
  type        = string
  default     = "eastus2"
}

variable "openai_models" {
  description = "The models to be deployed in the OpenAI resource."
  type        = list(string)
  default     = ["gpt-35-turbo"]

  validation {
    condition     = alltrue([for model in var.openai_models : contains(keys(var.openai_version_map), model)])
    error_message = "All models must exist in the version map."
  }
}

# Add or edit as required
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
  type    = string
  default = "/subscriptions/<subscription-id>/resourceGroups/<vnet-rg>/providers/Microsoft.Network/virtualNetworks/<vnet-name>"
}

variable "existing_resource_id_for_udr" {
  type    = string
  default = "/subscriptions/<subscription-id>/resourceGroups/<vnet-rg>/providers/Microsoft.Network/routeTables/<rtb-name>"
}

# If your organization has a specific set of IPs that need to be allowlisted, you can add them here.
variable "ingress_client_ip" {
  description = "Allowlist for Ingress IPs (CloudFlare WARP Proxy)."
  type        = list(string)
  default     = []
}

variable "bastion_subnet_prefix" {
  description = "CIDR prefix for the bastion (jumpbox) subnet."
  type        = string
}

variable "app_services_subnet_prefix" {
  description = "CIDR prefix for the app services subnet."
  type        = string
}

variable "app_gateway_subnet_prefix" {
  description = "CIDR prefix for the app gateway subnet."
  type        = string
}

variable "private_endpoints_subnet_prefix" {
  description = "CIDR prefix for the private endpoints subnet."
  type        = string
}

variable "agents_subnet_prefix" {
  description = "CIDR prefix for the agents subnet."
  type        = string
}

variable "jumpbox_subnet_prefix" {
  description = "CIDR prefix for the jumpbox subnet."
  type        = string
}

variable "telemetry_opt_out" {
  description = "Set to true to opt out of telemetry."
  type        = bool
  default     = false
}

variable "jump_box_admin_name" {
  description = "Name of the administrator account."
  type        = string
}

variable "jump_box_admin_password" {
  description = "Password for the administrator account."
  type        = string
  sensitive   = true
}