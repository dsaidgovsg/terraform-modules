#################################################
# AWS Authentication
#################################################
resource "vault_auth_backend" "aws" {
  type = "aws"
  path = "${var.aws_auth_path}"
}

resource "vault_aws_auth_backend_role" "consul" {
  backend            = "${vault_auth_backend.aws.path}"
  role               = "${var.consul_role}"
  auth_type          = "ec2"
  bound_iam_role_arn = "${var.consul_iam_role_arn}"
  policies           = "${concat(var.base_policies, var.consul_policies)}"
  period             = "${var.period_minutes}"
}

resource "vault_aws_auth_backend_role" "nomad_server" {
  backend            = "${vault_auth_backend.aws.path}"
  role               = "${var.nomad_server_role}"
  auth_type          = "ec2"
  bound_iam_role_arn = "${var.nomad_server_iam_role_arn}"
  policies           = "${concat(var.base_policies, var.nomad_server_policies)}"
  period             = "${var.period_minutes}"
}

resource "vault_aws_auth_backend_role" "nomad_client" {
  backend            = "${vault_auth_backend.aws.path}"
  role               = "${var.nomad_client_role}"
  auth_type          = "ec2"
  bound_iam_role_arn = "${var.nomad_client_iam_role_arn}"
  policies           = "${concat(var.base_policies, var.nomad_client_policies)}"
  period             = "${var.period_minutes}"
}

resource "vault_aws_auth_backend_role" "vault" {
  backend            = "${vault_auth_backend.aws.path}"
  role               = "${var.vault_role}"
  auth_type          = "ec2"
  bound_iam_role_arn = "${var.vault_iam_role_arn}"
  policies           = "${concat(var.base_policies, var.vault_policies)}"
  period             = "${var.period_minutes}"
}

################################################
# Mark in Consul for the `core` module scripts to configure themselves
################################################
resource "consul_key_prefix" "core_integration" {
  count       = "${var.core_integration ? 1 : 0}"
  path_prefix = "${var.consul_key_prefix}aws-auth/"

  subkeys {
    "enabled"            = "yes"
    "path"               = "${vault_auth_backend.aws.path}"
    "roles/consul"       = "${var.consul_role}"
    "roles/nomad_server" = "${var.nomad_server_role}"
    "roles/nomad_client" = "${var.nomad_client_role}"
    "roles/vault"        = "${var.vault_role}"
    "README"             = "This is used for integration with the `core` module. See https://github.com/GovTechSG/terraform-modules/tree/master/modules/aws-auth"
  }
}
