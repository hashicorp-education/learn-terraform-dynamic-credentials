# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "cluster-endpoint-url" {
  description = "URL of the cluster API server"
  value       = kubernetes_manifest.oidc_conf.object.spec.server
}

output "cluster-endpoint-ca" {
  description = "CA certificate of the cluster API server"
  value       = kubernetes_manifest.oidc_conf.object.spec.certificateAuthorityData
}
