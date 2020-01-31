output "path" {
  description = "Path to the Nomad secrets engine. Useful for implicit dependencies"
  value       = coalescelist(vault_mount.nomad.*.path, [""])[0]
}
