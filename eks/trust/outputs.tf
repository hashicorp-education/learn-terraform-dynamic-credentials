# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "cluster-endpoint-url" {
  description = "URL of the cluster API server"
  value       = data.aws_eks_cluster.upstream.endpoint
}

output "cluster-endpoint-ca" {
  description = "CA certificate of the cluster API server"
  value       = data.aws_eks_cluster.upstream.certificate_authority[0].data
}
