output "mount_path" {
  description = "Path where secret is mounted"
  value       = vault_mount.example.path
}

output "secret_name" {
  description = "Name of the secret stored"
  value       = vault_kv_secret_v2.example.name
}
