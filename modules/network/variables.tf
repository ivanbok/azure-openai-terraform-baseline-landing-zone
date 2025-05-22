variable "location" {
  description = "The resource group location"
  type        = string
}

variable "virtual_network_resource_group_name" {
  type        = string
  description = "The name of the resource group where the existing virtual network is located"
}

variable "vnet_name" {
  description = "Name of the existing virtual network (spoke) in this resource group."
  type        = string
}

variable "existing_udr_for_internet_traffic_name" {
  description = "Name of the existing Internet UDR in this resource group. This should be blank for VWAN deployments."
  type        = string
  default     = ""
}

variable "bastion_subnet_prefix" {
  description = "CIDR prefix for the bastion (jumpbox) subnet."
  type        = string
  default     = "10.0.0.0/24"

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
  default     = "10.0.1.0/24"

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
  default     = "10.0.2.0/24"

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
  default     = "10.0.3.0/24"

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
  default     = "10.0.4.0/24"

  validation {
    condition = can(regex(
      "^([0-9]{1,3}\\.){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$",
      var.jumpbox_subnet_prefix
    ))
    error_message = "The value must be a valid IPv4 CIDR block (e.g., 192.168.1.0/24)."
  }
}