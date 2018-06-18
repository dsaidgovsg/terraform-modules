output "server_role" {
  description = "Role name for Nomad servers"
  value       = "server"
}

output "client_role" {
  description = "Role name for Nomad clients"
  value       = "client"
}

output "ca_endpoints" {
  description = "URL to retrieve the CA for Nomad TLS"
  value       = " ${local.ca_endpoints}"
}

output "ca_chain_endpoints" {
  description = "URL to retrieve the CA for Nomad TLS"
  value       = " ${local.ca_chain_endpoints}"
}

output "crl_distribution_points" {
  description = "URL for CRL distribution"
  value       = "${local.crl_distribution_points}"
}

output "server_policy_name" {
  description = "Name of the policy to allow Nomad servers to request for certificates"
  value       = "${vault_policy.server.name}"
}

output "client_policy_name" {
  description = "Name of the policy to allow Nomad clients to request for certificates"
  value       = "${vault_policy.client.name}"
}
