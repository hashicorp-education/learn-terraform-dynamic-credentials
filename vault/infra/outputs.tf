output "secret_name" {
  description = "Name of the secret stored"
  value       = vault_kv_secret_v2.example.name
}

output "secret_path" {
  description = "Path to the secret"
  value       = vault_kv_secret_v2.example.path
}
