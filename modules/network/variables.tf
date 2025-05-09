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
}

variable "app_services_subnet_prefix" {
  description = "CIDR prefix for the app services subnet."
  type = string
}

variable "app_gateway_subnet_prefix" {
  description = "CIDR prefix for the app gateway subnet."
  type = string
}

variable "private_endpoints_subnet_prefix" {
  description = "CIDR prefix for the private endpoints subnet."
  type = string
}

variable "agents_subnet_prefix" {
  description = "CIDR prefix for the agents subnet."
  type = string
}

variable "jumpbox_subnet_prefix" {
  description = "CIDR prefix for the jumpbox subnet."
  type = string
}