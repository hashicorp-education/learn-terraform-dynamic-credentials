terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.44.1"
    }
  }
  cloud {
    workspaces {
      name = "learn-terraform-dynamic-credentials"
    }
  }
}
