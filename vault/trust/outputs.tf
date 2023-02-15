output "openid_claims" {
  description = "OpenID Claims for trust relationship"
  value       = vault_jwt_auth_backend_role.tfc_role.bound_claims
}

output "run_role" {
  description = "Name of the vault role for trust relationship"
  value       = vault_jwt_auth_backend_role.tfc_role.role_name
}
