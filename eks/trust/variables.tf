# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "cluster_name" {
  description = "Name of target EKS cluster"
  type        = string
}

variable "cluster_region" {
  description = "Location of the EKS cluster"
  type        = string
}

variable "tfc_hostname" {
  type        = string
  default     = "https://app.terraform.io"
  description = "The hostname of the TFC or TFE instance you'd like to use with EKS"
}

variable "tfc_kubernetes_audience" {
  type        = string
  default     = "kubernetes"
  description = "The audience value to use in run identity tokens if the default audience value is not desired."
}

variable "tfc_organization_name" {
  type        = string
  description = "The name of your Terraform Cloud organization"
}

variable "tfc_project_name" {
  type        = string
  default     = "Default Project"
  description = "The project under which a workspace will be created"
}

variable "tfc_workspace_name" {
  type        = string
  default     = "learn-terraform-dynamic-credentials"
  description = "The name of the workspace that you'd like to create and connect to"
}