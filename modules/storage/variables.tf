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
  description = "The name of the resource group containing the workload resources."
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

variable "log_workspace_id" {
  description = "The resource ID of existing Log Analytics workspace."
  type        = string
}

variable "ingress_client_ip" {
  description = "Allowlist for Ingress IPs (CloudFlare WARP Proxy)."
  type        = list(string)
}