terraform {
  required_version = "~> 1.7"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.5"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}