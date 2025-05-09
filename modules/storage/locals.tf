locals {
  app_deploy_storage_name             = "stg${var.base_name}"
  app_deploy_storage_private_endpoint = "pep-st${var.base_name}"
  ml_storage_name                     = "stml${var.base_name}"
  ml_blob_storage_private_endpoint    = "pep-blob-stml${var.base_name}"
  ml_file_storage_private_endpoint    = "pep-file-stml${var.base_name}"
}