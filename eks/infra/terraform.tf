# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  cloud {
    organization = "k8s-dynamic-creds"

    workspaces {
      name = "docs-testing"
    }
  }
}