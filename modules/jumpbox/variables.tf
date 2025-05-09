variable "base_name" {
  description = "This is the base name for each Azure resource name (6-12 chars)"
  type        = string
  validation {
    condition     = length(var.base_name) >= 6 && length(var.base_name) <= 12
    error_message = "Base name must be between 6 and 12 characters."
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
}

variable "jump_box_admin_name" {
  description = "Name of the administrator account."
  type        = string
  default     = "vmadmin"
}

variable "jump_box_admin_password" {
  description = "Password for the administrator account."
  type        = string
  sensitive   = true
}

variable "log_workspace_name" {
  description = "Name of the Log Analytics workspace."
  type        = string
}

variable "log_workspace_id" {
  description = "The resource ID of existing Log Analytics workspace."
  type        = string
}