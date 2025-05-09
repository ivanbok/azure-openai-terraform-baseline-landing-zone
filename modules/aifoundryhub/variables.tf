variable "base_name" {
  description = "This is the base name for each Azure resource name (6-12 chars)"
  type        = string
  validation {
    condition     = length(var.base_name) >= 6 && length(var.base_name) <= 12
    error_message = "Base name must be between 6 and 12 characters."
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

variable "virtual_network_resource_group_name" {
  description = "The name of the resource group containing the spoke virtual network."
  type        = string
}

variable "private_endpoints_subnet_id" {
  description = "Subnet id for private endpoints."
  type        = string
}

variable "appinsights_id" {
  description = "The ID of the Application Insights resource to use for the workspace."
  type = string
}

variable "container_registry_id" {
  description = "The ID of the container registry to use for the workspace."
  type = string
}

variable "key_vault_id" {
  description = "The ID of the Key Vault to use for the workspace."
  type        = string
}

variable "ai_foundry_storage_account_id" {
  description = "The name of the storage account to use for the workspace."
  type        = string
}

variable "log_workspace_id" {
  description = "The resource ID of existing Log Analytics workspace."
  type        = string
}

variable "openai_resource_name" {
  description = "The ID of the OpenAI Cognitive Services Account to use for the workspace."
  type        = string
}

variable "openai_resource_id" {
  description = "The ID of the OpenAI Cognitive Services Account to use for the workspace."
  type        = string
}

variable "openai_endpoint" {
  description = "The endpoint of the OpenAI Cognitive Services Account to use for the workspace."
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

variable "ai_search_resource_name" {
  description = "The name of the AI Search resource."
  type        = string
}

variable "ingress_client_ip" {
  description = "Allowlist for Ingress IPs (CloudFlare WARP Proxy)."
  type        = list(string)
}