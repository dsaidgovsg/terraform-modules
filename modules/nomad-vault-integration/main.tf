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
# Nomad servers created Token Role
################################################
locals {
  disallowed_policies = "${concat([var.nomad_server_policy], var.disallowed_policies)}"
}

data "template_file" "nomad_server_token_role" {
  template = "${file("${path.module}/templates/vault_token_role.json")}"

  vars {
    disallowed_policies = "${join(", ", formatlist("\"%s\"", local.disallowed_policies))}"
    nomad_token_role    = "${var.nomad_token_role}"
    path_suffix         = "${var.nomad_token_suffix}"
  }
}

resource "vault_generic_secret" "nomad_server_token_role" {
  depends_on = ["vault_policy.nomad_server_policy"]

  path      = "auth/token/roles/${var.nomad_token_role}"
  data_json = "${data.template_file.nomad_server_token_role.rendered}"
}

################################################
# Mark in Consul for the `core` module scripts to configure themselves
################################################
resource "consul_key_prefix" "core_integration" {
  depends_on = [
    "vault_auth_backend.aws",
    "vault_policy.nomad_server_policy",
    "vault_generic_secret.nomad_aws_token_role",
    "vault_generic_secret.nomad_server_token_role",
  ]

  count       = "${var.core_integration ? 1 : 0}"
  path_prefix = "${var.consul_key_prefix}nomad-vault-integration/"

  subkeys {
    "enabled"               = "yes"
    "allow_unauthenticated" = "${var.allow_unauthenticated}"
    "create_from_role"      = "${var.nomad_token_role}"
    "nomad_server_policy"   = "${var.nomad_server_policy}"
    "README"                = "This is used for integration with the `core` module. See https://github.com/GovTechSG/terraform-modules/tree/master/modules/nomad-vault-integration"
  }
}
