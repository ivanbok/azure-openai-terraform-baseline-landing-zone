variable "base_name" {
  description = "This is the base name for each Azure resource name"
  type        = string
}

variable "location" {
  description = "The resource group location"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "default_tags" {
  description = "Default tags to be applied to all resources."
  type        = map(string)
}