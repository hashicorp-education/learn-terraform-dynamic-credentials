output "openid_claims" {
  description = "OpenID Claims for trust relationship."
  value       = google_iam_workload_identity_pool_provider.tfc_provider.attribute_condition
}

output "service_account_email" {
  description = "Email address of service account used by trust relationship."
  value       = google_service_account.tfc_service_account.email
}

output "project_id" {
  description = "Project ID associated with trust relationship. Not the same as project number."
  value       = var.gcp_project_id
}

output "project_number" {
  description = "Project number associated with trust relationship. Not the same as project ID."
  value       = data.google_project.project.number
}

output "workload_pool_id" {
  description = "ID of the workload identity pool for the trust relationship."
  value       = google_iam_workload_identity_pool.tfc_pool.workload_identity_pool_id
}

output "workload_provider_id" {
  description = "ID of the workload provider for the trust relationship."
  value       = google_iam_workload_identity_pool_provider.tfc_provider.workload_identity_pool_provider_id
}

output "workload_identity_audience" {
  description = "The audience of the workload identity associated with the trust relationship."
  value       = one(google_iam_workload_identity_pool_provider.tfc_provider.oidc).allowed_audiences
}