output "cluster_size" {
  description = "Number of Nomad Clients in the cluster"
  value       = "${module.nomad_clients.cluster_size}"
}

output "client_node_class" {
  description = "Nomad Client Node Class name applied"
  value       = "${var.client_node_class}"
}

output "asg_name" {
  description = "Name of auto-scaling group for Nomad Clients"
  value       = "${module.nomad_clients.asg_name}"
}

output "launch_config_name" {
  description = "Name of launch config for Nomad Clients"
  value       = "${module.nomad_clients.launch_config_name}"
}

output "iam_role_arn" {
  description = "IAM Role ARN for Nomad Clients"
  value       = "${module.nomad_clients.iam_role_arn}"
}

output "iam_role_id" {
  description = "IAM Role ID for Nomad Clients"
  value       = "${module.nomad_clients.iam_role_id}"
}

output "security_group_id" {
  description = "Security group ID for Nomad Clients"
  value       = "${module.nomad_clients.security_group_id}"
}

output "default_user_data" {
  description = "Default launch configuration user data for Nomad Clients"
  value       = "${data.template_file.user_data_nomad_client.rendered}"
}

output "ssh_key_name" {
  description = "Name of SSH Key for SSH login authentication to Nomad Clients cluster"
  value       = "${var.ssh_key_name}"
}
