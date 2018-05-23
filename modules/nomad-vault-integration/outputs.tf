output "nomad_server_policy_name" {
  description = "Name of policy that Nomad servers should have"
  value       = "${var.nomad_server_policy}"
}

output "nomad_server_policy" {
  description = "Policy for Nomad servers"
  value       = "${data.template_file.nomad_server_policy.rendered}"
}

output "nomad_server_token_role" {
  description = "Configuration for Nomad server token role"
  value       = "${data.template_file.nomad_server_token_role.rendered}"
}
