terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.23.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
  }
}
