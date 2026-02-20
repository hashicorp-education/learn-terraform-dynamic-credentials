terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.58.1"
    }
  }
  cloud {
    workspaces {
      name = "learn-terraform-dynamic-credentials"
    }
  }
}
