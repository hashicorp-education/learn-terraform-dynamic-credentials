terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.12.0"
    }
  }
  # cloud {
  #   workspaces {
  #     name = "learn-terraform-dynamic-credentials"
  #   }
  # }
}
