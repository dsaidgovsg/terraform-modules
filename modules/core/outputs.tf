output "num_nomad_servers" {
  description = "Number of Nomad servers in the cluster"
  value       = "${module.nomad_servers.cluster_size}"
}

output "asg_name_nomad_servers" {
  description = "Name of Nomad Server Autoscaling group"
  value       = "${module.nomad_servers.asg_name}"
}

output "launch_config_name_nomad_servers" {
  description = "Name of Launch Configuration for Nomad servers"
  value       = "${module.nomad_servers.launch_config_name}"
}

output "iam_role_arn_nomad_servers" {
  description = "IAM Role ARN for Nomad servers"
  value       = "${module.nomad_servers.iam_role_arn}"
}

output "iam_role_id_nomad_servers" {
  description = "IAM Role ID for Nomad servers"
  value       = "${module.nomad_servers.iam_role_id}"
}

output "security_group_id_nomad_servers" {
  description = "Security Group ID for Nomad servers"
  value       = "${module.nomad_servers.security_group_id}"
}

output "num_consul_servers" {
  description = "Number of Consul servers in cluster"
  value       = "${module.consul_servers.cluster_size}"
}

output "asg_name_consul_servers" {
  description = "Name of Consul Server Autoscaling group"
  value       = "${module.consul_servers.asg_name}"
}

output "launch_config_name_consul_servers" {
  description = "Name of the Launch Configuration for Consul servers"
  value       = "${module.consul_servers.launch_config_name}"
}

output "iam_role_arn_consul_servers" {
  description = "IAM Role ARN for Consul servers"
  value       = "${module.consul_servers.iam_role_arn}"
}

output "iam_role_id_consul_servers" {
  description = "IAM Role ID for Consul servers"
  value       = "${module.consul_servers.iam_role_id}"
}

output "security_group_id_consul_servers" {
  description = "Security Group ID for Consul servers"
  value       = "${module.consul_servers.security_group_id}"
}

output "meta_tag_value_nomad_clients" {
  description = "Nomad Client Meta tag value applied"
  value       = "${module.nomad_clients.client_meta_tag_value}"
}

output "num_nomad_clients" {
  description = "The desired number of Nomad clients in cluster"
  value       = "${module.nomad_clients.cluster_size}"
}

output "asg_name_nomad_clients" {
  description = "Name of the Autoscaling group for Nomad Clients"
  value       = "${module.nomad_clients.asg_name}"
}

output "launch_config_name_nomad_clients" {
  description = "Name of the Launch Configuration for Nomad Clients"
  value       = "${module.nomad_clients.launch_config_name}"
}

output "iam_role_arn_nomad_clients" {
  description = "IAM Role ARN for Nomad Clients"
  value       = "${module.nomad_clients.iam_role_arn}"
}

output "iam_role_id_nomad_clients" {
  description = "IAM Role ID for Nomad Clients"
  value       = "${module.nomad_clients.iam_role_id}"
}

output "security_group_id_nomad_clients" {
  description = "Security Group ID for Nomad Clients"
  value       = "${module.nomad_clients.security_group_id}"
}

output "nomad_servers_cluster_tag_key" {
  description = "Key that Nomad Server Instances are tagged with for discovery"
  value       = "${module.nomad_servers.cluster_tag_key}"
}

output "nomad_servers_cluster_tag_value" {
  description = "Value that Nomad servers are tagged with for discovery"
  value       = "${module.nomad_servers.cluster_tag_value}"
}

output "nomad_api_address" {
  description = "Address to access nomad API"
  value       = "${var.nomad_api_domain}"
}

output "consul_api_address" {
  description = "Address to access consul API"
  value       = "${var.consul_api_domain}"
}

output "vault_api_address" {
  description = "Address to access Vault API"
  value       = "${var.vault_api_domain}"
}

output "vault_asg_name" {
  description = "Name of the Autoscaling group for Vault cluster"
  value       = "${module.vault.asg_name}"
}

output "vault_cluster_size" {
  description = "Number of instances in the Vault cluster"
  value       = "${module.vault.cluster_size}"
}

output "vault_launch_config_name" {
  description = "Name of the Launch Configuration for Vault cluster"
  value       = "${module.vault.launch_config_name}"
}

output "vault_iam_role_arn" {
  description = "IAM Role ARN for Vault"
  value       = "${module.vault.iam_role_arn}"
}

output "vault_iam_role_id" {
  description = "IAM Role ID for Vault"
  value       = "${module.vault.iam_role_id}"
}

output "vault_security_group_id" {
  description = "ID of the Security Group for Vault"
  value       = "${module.vault.security_group_id}"
}

output "vault_s3_bucket_arn" {
  description = "ARN of the S3 bucket that Vault's state is stored"
  value       = "${module.vault.s3_bucket_arn}"
}

output "vault_servers_cluster_tag_key" {
  description = "Key that Vault instances are tagged with"
  value       = "${module.vault.cluster_tag_key}"
}

output "vault_servers_cluster_tag_value" {
  description = "Value that Vault instances are tagged with"
  value       = "${module.vault.cluster_tag_value}"
}

output "internal_lb_id" {
  description = "ID of the internal LB that exposes Nomad, Consul and Vault RPC"
  value       = "${aws_security_group.internal_lb.id}"
}

output "internal_lb_https_listener_arn" {
  description = "ARN of the HTTPS listener for the internal LB"

  # Use the `aws_lb_listener_certificate` resource to attach additional certificates
  value = "${aws_lb_listener.internal_https.arn}"
}

output "consul_server_default_user_data" {
  description = "Default launch configuration user data for Consul Server"
  value       = "${data.template_file.user_data_consul_server.rendered}"
}

output "nomad_client_default_user_data" {
  description = "Default launch configuration user data for Nomad Client"
  value       = "${module.nomad_clients.default_user_data}"
}

output "nomad_server_default_user_data" {
  description = "Default launch configuration user data for Nomad Server"
  value       = "${data.template_file.user_data_nomad_server.rendered}"
}

output "vault_cluster_default_user_data" {
  description = "Default launch configuration user data for Vault Cluster"
  value       = "${data.template_file.user_data_vault_cluster.rendered}"
}

output "ssh_key_name" {
  description = "The name of the SSH key that all instances are launched with"
  value       = "${var.ssh_key_name}"
}
