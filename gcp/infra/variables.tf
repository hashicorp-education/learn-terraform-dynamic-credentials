variable "machine_type" {
  description = "Type of compute instance to use"
  default     = "f1-micro"
  type        = string
}

variable "tags" {
  description = "Tags for instances"
  type        = list(string)
  default     = []
}

variable "gcp_region" {
  type        = string
  default     = "us-east1"
  description = "GCP region for all resources"
}

variable "gcp_zone" {
  type        = string
  default     = "us-east1-b"
  description = "GCP zone for all resources"
}

variable "gcp_project_id" {
  type        = string
  description = "GCP project ID for all resources"
}
