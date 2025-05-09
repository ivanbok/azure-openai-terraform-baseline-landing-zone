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
  description = "The name of the resource group"
  type        = string
}
