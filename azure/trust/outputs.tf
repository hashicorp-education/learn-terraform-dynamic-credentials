output "subscription_id" {
  description = "Azure subscription ID"
  value       = data.azurerm_subscription.current.subscription_id
}

output "tenant_id" {
  description = "Azure tenant ID"
  value       = data.azurerm_subscription.current.tenant_id
}

output "run_client_id" {
  description = "Client ID for trust relationship"
  value       = azuread_application.tfc_application.application_id
}

output "openid_claims" {
  description = "OpenID Claims for trust relationship"
  value = [
    azuread_application_federated_identity_credential.tfc_federated_credential_plan.subject,
    azuread_application_federated_identity_credential.tfc_federated_credential_apply.subject,
  ]
}
