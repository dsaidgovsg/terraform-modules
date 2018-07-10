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

output "nomad_client_default_user_data" {
  description = "Default launch configuration user data for Nomad Client"
  value       = "${data.template_file.user_data_nomad_client.rendered}"
}

output "ssh_key_name" {
  value = "${var.ssh_key_name}"
}
