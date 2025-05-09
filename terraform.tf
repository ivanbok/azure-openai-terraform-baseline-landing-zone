terraform {
  required_version = "~> 1.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    azapi = {
      source = "Azure/azapi"
      version = "~> 2.0"
    }

    http = {
      source = "hashicorp/http"
    }

    # # No longer needed as we are using Azure Naming Module for Randomization
    # random = {
    #   source  = "hashicorp/random"
    #   version = "~> 3.5"
    # }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# To make a HTTP call to get the IP address of the client for whitelisting AKV
provider "http" {}

provider "azapi" {
  # The Azure API provider is used to create resources that are not yet supported by the azurerm provider.
  subscription_id = var.subscription_id
}