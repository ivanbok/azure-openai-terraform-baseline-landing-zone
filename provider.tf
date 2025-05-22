provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "http" {}

provider "azapi" {
  subscription_id = var.subscription_id
}