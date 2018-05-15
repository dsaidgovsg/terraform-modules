output "nomad_server_policy" {
  value = "${data.template_file.nomad_server_policy.rendered}"
}

output "nomad_aws_token_role" {
  value = "${data.template_file.nomad_aws_token_role.rendered}"
}

output "nomad_server_token_role" {
  value = "${data.template_file.nomad_server_token_role.rendered}"
}
