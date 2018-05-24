output "nomad_server_policy_name" {
  description = "Name of policy that allows the creation of a token to pass to the Nomad cluster servers"
  value       = "${var.nomad_server_policy}"
}

output "nomad_server_policy" {
  description = "Policy that allows the creation of a token to pass to the Nomad cluster servers"
  value       = "${data.template_file.nomad_server_policy.rendered}"
}

output "nomad_server_token_role" {
  description = "Token role configuration to create a token with the nomad_cluster policy"
  value       = "${data.template_file.nomad_server_role.rendered}"
}

output "nomad_cluster_policy_name" {
  description = "Name of policy allows Nomad servers to create child tokens for jobs"
  value       = "${var.nomad_cluster_policy}"
}

output "nomad_cluster_policy" {
  description = "Policy allows Nomad servers to create child tokens for jobs"
  value       = "${data.template_file.nomad_cluster_policy.rendered}"
}

output "nomad_cluster_token_role" {
  description = "Token role configuration to allow Nomad servers to create child tokens"
  value       = "${data.template_file.nomad_cluster_role.rendered}"
}
