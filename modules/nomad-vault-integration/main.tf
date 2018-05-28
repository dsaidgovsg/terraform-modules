# Based on https://www.nomadproject.io/docs/vault-integration/index.html

################################################
# Nomad Server Policy
# This policy allows creation of a periodic token to pass to Nomad servers using the
# `nomad_server_role`.
#
# The token your EC2 instances are given should have this policy attached.
################################################
data "template_file" "nomad_server_policy" {
  template = "${file("${path.module}/templates/nomad_server_policy.hcl")}"

  vars {
    nomad_server_role = "${var.nomad_server_role}"
  }
}

resource "vault_policy" "nomad_server_policy" {
  name = "${var.nomad_server_policy}"

  policy = "${data.template_file.nomad_server_policy.rendered}"
}

################################################
# Nomad Server Role
# Token role to create tokens for Nomad servers
################################################
locals {
  nomad_server_allowed_policies = ["${vault_policy.nomad_cluster_policy.name}"]
}

data "template_file" "nomad_server_role" {
  template = "${file("${path.module}/templates/nomad_server_role.json")}"

  vars {
    allowed_policies  = "${join(", ", formatlist("\"%s\"", local.nomad_server_allowed_policies))}"
    nomad_server_role = "${var.nomad_server_role}"
  }
}

resource "vault_generic_secret" "nomad_server_role" {
  path      = "auth/token/roles/${var.nomad_server_role}"
  data_json = "${data.template_file.nomad_server_role.rendered}"
}

################################################
# Nomad Cluster Policy
# This policy allows Nomad servers to create child tokens for jobs
################################################
data "template_file" "nomad_cluster_policy" {
  template = "${file("${path.module}/templates/nomad_cluster_policy.hcl")}"

  vars {
    nomad_cluster_role = "${var.nomad_cluster_role}"
  }
}

resource "vault_policy" "nomad_cluster_policy" {
  name = "${var.nomad_cluster_policy}"

  policy = "${data.template_file.nomad_cluster_policy.rendered}"
}

################################################
# Nomad Cluster Role
# Token role for Nomad servers to create token
################################################
locals {
  nomad_cluster_disallowed_defaults = ["${vault_policy.nomad_cluster_policy.name}", "${vault_policy.nomad_server_policy.name}"]
  nomad_cluster_disallowed_policies = "${sort(concat(local.nomad_cluster_disallowed_defaults, var.nomad_cluster_disallowed_policies))}"
}

data "template_file" "nomad_cluster_role" {
  template = "${file("${path.module}/templates/nomad_cluster_role.json")}"

  vars {
    disallowed_policies = "${join(", ", formatlist("\"%s\"", local.nomad_cluster_disallowed_policies))}"
    nomad_cluster_role  = "${var.nomad_cluster_role}"
    path_suffix         = "${var.nomad_cluster_suffix}"
  }
}

resource "vault_generic_secret" "nomad_cluster_role" {
  path      = "auth/token/roles/${var.nomad_cluster_role}"
  data_json = "${data.template_file.nomad_cluster_role.rendered}"
}

################################################
# Mark in Consul for the `core` module scripts to configure themselves
################################################
resource "consul_key_prefix" "core_integration" {
  depends_on = [
    "vault_policy.nomad_server_policy",
    "vault_policy.nomad_cluster_policy",
    "vault_generic_secret.nomad_server_role",
    "vault_generic_secret.nomad_cluster_role",
  ]

  count       = "${var.core_integration ? 1 : 0}"
  path_prefix = "${var.consul_key_prefix}nomad-vault-integration/"

  subkeys {
    "enabled"               = "yes"
    "allow_unauthenticated" = "${var.allow_unauthenticated}"
    "nomad_server_role"     = "${var.nomad_server_role}"
    "nomad_cluster_role"    = "${var.nomad_cluster_role}"
    "README"                = "This is used for integration with the `core` module. See https://github.com/GovTechSG/terraform-modules/tree/master/modules/nomad-vault-integration"
  }
}
