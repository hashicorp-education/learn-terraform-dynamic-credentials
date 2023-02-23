output "openid_claims" {
  description = "OpenID Claims for trust relationship"
  value = [
    azuread_application_federated_identity_credential.tfc_federated_credential_plan.subject,
    azuread_application_federated_identity_credential.tfc_federated_credential_apply.subject,
  ]
}

output "run_client_id" {
  description = "Client ID for trust relationship"
  value       = azuread_application.tfc_application.application_id
}
