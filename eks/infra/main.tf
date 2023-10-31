# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "kubernetes" {
  host                   = var.cluster-endpoint-url
  cluster_ca_certificate = base64decode(var.cluster-endpoint-ca)

  // Auth token value will be obtained from the KUBE_TOKEN environment variable,
  // which gets automatically set by Terraform Cloud
}

resource "kubernetes_config_map" "test" {
  metadata {
    name = "test"
  }

  data = {
    "foo" = "bar"
  }
}
