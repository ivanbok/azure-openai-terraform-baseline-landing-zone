locals {
  existing_spoke_vnet_parts = split("/", var.existing_resource_id_for_spoke_vnet)
  spoke_rg_name             = local.existing_spoke_vnet_parts[4]
  spoke_vnet_name           = local.existing_spoke_vnet_parts[8]

  existing_udr_parts = split("/", var.existing_resource_id_for_udr)
  udr_name           = length(local.existing_udr_parts) > 8 ? local.existing_udr_parts[8] : ""
}