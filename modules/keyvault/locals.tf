locals {
  my_ip_cidr                   = "${trimspace(data.http.my_ip.response_body)}/32"
  key_vault_name               = module.naming.key_vault.name_unique
  key_vault_secrets_officer_id = "/providers/Microsoft.Authorization/roleDefinitions/b86a8fe4-44ce-4948-aee5-eccb2c155cd7"
}