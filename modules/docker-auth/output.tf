output "policy" {
  description = "Name of policy to allow access to the Docker Authentication secrets"
  value       = "${vault_policy.policy.name}"
}
