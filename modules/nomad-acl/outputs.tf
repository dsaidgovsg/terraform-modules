output "path" {
  description = "Path to the Nomad secrets engine. Useful for implicit dependencies"
  value       = "${vault_mount.nomad.path}"
}
