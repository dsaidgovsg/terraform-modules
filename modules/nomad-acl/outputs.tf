output "path" {
  description = "Path to the Nomad secrets engine. Useful for implicit dependencies"
  value       = "${element(coalescelist(vault_mount.nomad.*.path, list("")), 0)}"
}
