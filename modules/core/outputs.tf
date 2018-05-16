output "num_nomad_servers" {
  value = "${module.nomad_servers.cluster_size}"
}

output "asg_name_nomad_servers" {
  value = "${module.nomad_servers.asg_name}"
}

output "launch_config_name_nomad_servers" {
  value = "${module.nomad_servers.launch_config_name}"
}

output "iam_role_arn_nomad_servers" {
  value = "${module.nomad_servers.iam_role_arn}"
}

output "iam_role_id_nomad_servers" {
  value = "${module.nomad_servers.iam_role_id}"
}

output "security_group_id_nomad_servers" {
  value = "${module.nomad_servers.security_group_id}"
}

output "num_consul_servers" {
  value = "${module.consul_servers.cluster_size}"
}

output "asg_name_consul_servers" {
  value = "${module.consul_servers.asg_name}"
}

output "launch_config_name_consul_servers" {
  value = "${module.consul_servers.launch_config_name}"
}

output "iam_role_arn_consul_servers" {
  value = "${module.consul_servers.iam_role_arn}"
}

output "iam_role_id_consul_servers" {
  value = "${module.consul_servers.iam_role_id}"
}

output "security_group_id_consul_servers" {
  value = "${module.consul_servers.security_group_id}"
}

output "num_nomad_clients" {
  value = "${module.nomad_clients.cluster_size}"
}

output "asg_name_nomad_clients" {
  value = "${module.nomad_clients.asg_name}"
}

output "launch_config_name_nomad_clients" {
  value = "${module.nomad_clients.launch_config_name}"
}

output "iam_role_arn_nomad_clients" {
  value = "${module.nomad_clients.iam_role_arn}"
}

output "iam_role_id_nomad_clients" {
  value = "${module.nomad_clients.iam_role_id}"
}

output "security_group_id_nomad_clients" {
  value = "${module.nomad_clients.security_group_id}"
}

output "nomad_servers_cluster_tag_key" {
  value = "${module.nomad_servers.cluster_tag_key}"
}

output "nomad_servers_cluster_tag_value" {
  value = "${module.nomad_servers.cluster_tag_value}"
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
  value = "${module.vault.asg_name}"
}

output "vault_cluster_size" {
  value = "${module.vault.cluster_size}"
}

output "vault_launch_config_name" {
  value = "${module.vault.launch_config_name}"
}

output "vault_iam_role_arn" {
  value = "${module.vault.iam_role_arn}"
}

output "vault_iam_role_id" {
  value = "${module.vault.iam_role_id}"
}

output "vault_security_group_id" {
  value = "${module.vault.security_group_id}"
}

output "vault_s3_bucket_arn" {
  value = "${module.vault.s3_bucket_arn}}"
}

output "vault_servers_cluster_tag_key" {
  value = "${module.vault.cluster_tag_key}"
}

output "vault_servers_cluster_tag_value" {
  value = "${module.vault.cluster_tag_value}"
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${var.vpc_id}"
}

output "vpc_public_subnets" {
  description = "Public subnets for the VPC"
  value       = "${var.vpc_public_subnets}"
}

output "vpc_region" {
  description = "The region the infra belongs to"
  value       = "${var.vpc_region}"
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

output "ssh_key_name" {
  value = "${var.ssh_key_name}"
}
