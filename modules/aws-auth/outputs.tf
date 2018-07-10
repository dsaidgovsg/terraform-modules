output "path" {
  description = "Path to the AWS authentication mount"
  value       = "${vault_auth_backend.aws.path}"
}
