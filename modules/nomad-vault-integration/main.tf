#################################################
# AWS Authentication
#################################################
resource "vault_auth_backend" "aws" {
    type = "aws"
    path = "${var.aws_path}"
}

################################################
# Nomad Server Policy
# See https://www.nomadproject.io/docs/vault-integration/index.html
################################################
data "template_file" "nomad_server_policy" {
    template = "${file("${path.module}/templates/nomad_server_policy.hcl")}"

    vars {
        nomad_token_role = "${var.nomad_token_role}"
    }
}

resource "vault_policy" "nomad_server_policy" {
    name = "${var.nomad_server_policy}"

    policy = "${data.template_file.nomad_server_policy.rendered}"
}

################################################
# AWS Authentication Token Role
################################################
data "template_file" "nomad_aws_token_role" {
    template = "${file("${path.module}/templates/vault_aws_role.json")}"

    vars {
        nomad_server_policy = "${var.nomad_server_policy}"
        nomad_token_role = "${var.nomad_token_role}"
        nomad_server_iam_role_arn = "${var.nomad_server_iam_role_arn}"
    }
}

resource "vault_generic_secret" "nomad_aws_token_role" {
    depends_on = ["vault_auth_backend.aws"]

    path = "auth/${var.aws_path}/role/${var.nomad_token_role}"
    data_json = "${data.template_file.nomad_aws_token_role.rendered}"
}

################################################
# Nomad servers created Token Role
################################################
data "template_file" "nomad_server_token_role" {
    template = "${file("${path.module}/templates/vault_token_role.json")}"

    vars {
        nomad_server_policy = "${var.nomad_server_policy}"
        nomad_token_role = "${var.nomad_token_role}"
    }
}

resource "vault_generic_secret" "nomad_server_token_role" {
    depends_on = ["vault_policy.nomad_server_policy"]

    path = "auth/token/roles/${var.nomad_token_role}"
    data_json = "${data.template_file.nomad_server_token_role.rendered}"
}
