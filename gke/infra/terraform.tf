# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }

  cloud {
    workspaces {
      name = "learn-terraform-dynamic-credentials"
    }
  }
}
