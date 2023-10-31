# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "cluster-endpoint-url" {
  type        = string
  description = "URL of GKE cluster's API"
}

variable "cluster-endpoint-ca" {
  type        = string
  description = "Base64 encoded CA certificate of the GKE cluster API endpoint"
}
