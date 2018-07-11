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
  policies           = ["${sort(concat(var.base_policies, var.consul_policies))}"]
  period             = "${var.period_minutes}"
}

resource "vault_aws_auth_backend_role" "nomad_server" {
  backend            = "${vault_auth_backend.aws.path}"
  role               = "${var.nomad_server_role}"
  auth_type          = "ec2"
  bound_iam_role_arn = "${var.nomad_server_iam_role_arn}"
  policies           = ["${sort(concat(var.base_policies, var.nomad_server_policies))}"]
  period             = "${var.period_minutes}"
}

resource "vault_aws_auth_backend_role" "nomad_client" {
  backend            = "${vault_auth_backend.aws.path}"
  role               = "${var.nomad_client_role}"
  auth_type          = "ec2"
  bound_iam_role_arn = "${var.nomad_client_iam_role_arn}"
  policies           = ["${sort(concat(var.base_policies, var.nomad_client_policies))}"]
  period             = "${var.period_minutes}"
}

resource "vault_aws_auth_backend_role" "vault" {
  backend            = "${vault_auth_backend.aws.path}"
  role               = "${var.vault_role}"
  auth_type          = "ec2"
  bound_iam_role_arn = "${var.vault_iam_role_arn}"
  policies           = ["${sort(concat(var.base_policies, var.vault_policies))}"]
  period             = "${var.period_minutes}"
}

resource "vault_aws_auth_backend_role" "emr_instance" {
  backend            = "${vault_auth_backend.aws.path}"
  role               = "${var.emr_instance_role}"
  auth_type          = "ec2"
  bound_iam_role_arn = "${var.emr_instance_iam_role_arn}"
  policies           = ["${sort(concat(var.base_policies, var.emr_instance_policies))}"]
  period             = "${var.period_minutes}"
}

################################################
# Mark in Consul for the `core` module scripts to configure themselves
################################################
resource "consul_keys" "enabled" {
  count = "${var.core_integration ? 1 : 0}"

  key {
    path   = "${var.consul_key_prefix}aws-auth/enabled"
    value  = "yes"
    delete = true
  }
}

resource "consul_keys" "path" {
  count = "${var.core_integration ? 1 : 0}"

  key {
    path   = "${var.consul_key_prefix}aws-auth/path"
    value  = "${vault_auth_backend.aws.path}"
    delete = true
  }
}

resource "consul_keys" "readme" {
  count = "${var.core_integration ? 1 : 0}"

  key {
    path = "${var.consul_key_prefix}aws-auth/README"

    value = <<EOF
This is used for integration with the `core` module.
See https://github.com/GovTechSG/terraform-modules/tree/master/modules/aws-auth
EOF

    delete = true
  }
}

resource "consul_keys" "consul" {
  count = "${var.core_integration ? 1 : 0}"

  key {
    path   = "${var.consul_key_prefix}aws-auth/roles/consul"
    value  = "${var.consul_role}"
    delete = true
  }
}

resource "consul_keys" "nomad_server" {
  count = "${var.core_integration ? 1 : 0}"

  key {
    path   = "${var.consul_key_prefix}aws-auth/roles/nomad_server"
    value  = "${var.nomad_server_role}"
    delete = true
  }
}

resource "consul_keys" "nomad_client" {
  count = "${var.core_integration ? 1 : 0}"

  key {
    path   = "${var.consul_key_prefix}aws-auth/roles/nomad_client"
    value  = "${var.nomad_client_role}"
    delete = true
  }
}

resource "consul_keys" "vault" {
  count = "${var.core_integration ? 1 : 0}"

  key {
    path   = "${var.consul_key_prefix}aws-auth/roles/vault"
    value  = "${var.vault_role}"
    delete = true
  }
}

resource "consul_keys" "emr_instance" {
  count = "${var.core_integration ? 1 : 0}"

  key {
    path   = "${var.consul_key_prefix}aws-auth/roles/emr_instance"
    value  = "${var.emr_instance_role}"
    delete = true
  }
}
