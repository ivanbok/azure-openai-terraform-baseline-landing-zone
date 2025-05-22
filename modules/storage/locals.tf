locals {
  my_ip                   = trimspace(data.http.my_ip.response_body)
  app_deploy_storage_name = module.app_deploy_storage_account_naming.storage_account.name_unique
  ml_storage_name         = module.ml_deploy_storage_account_naming.storage_account.name_unique
}