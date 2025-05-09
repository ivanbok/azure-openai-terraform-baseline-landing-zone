locals {
  openai_name                = "oai-${var.base_name}"
  openai_private_endpoint    = "pep-${local.openai_name}"
}