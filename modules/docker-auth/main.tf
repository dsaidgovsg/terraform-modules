locals {
  kv_path = "${var.kv_path}/${var.kv_subpath}"
}

################################################
# Policy to allow reading and listing of Docker auth credentials
# You need to include this policy with the tokens issued to Nomad Clients
################################################
data "template_file" "policy" {
  template = "${file("${path.module}/templates/policy.hcl")}"

  vars {
    kv_path = "${local.kv_path}"
  }
}

resource "vault_policy" "policy" {
  name = "${var.policy_name}"

  policy = "${data.template_file.policy.rendered}"
}

################################################
# Optional mounting of a KV store
################################################
resource "vault_mount" "kv" {
  count = "${var.provision_kv_store ? 1 : 0}"
  path  = "${var.kv_path}"
  type  = "kv"
}

################################################
# Registries Secrets
################################################

resource "vault_generic_secret" "registries" {
  path      = "${local.kv_path}"
  data_json = "${jsonencode(var.registries)}"
}

################################################
# Mark in Consul for the `core` module scripts to configure themselves
################################################
resource "consul_key_prefix" "core_integration" {
  depends_on = [
    "vault_mount.kv",
    "vault_policy.policy",
    "vault_generic_secret.registries",
  ]

  count       = "${var.core_integration ? 1 : 0}"
  path_prefix = "${var.consul_key_prefix}docker-auth/"

  subkeys {
    "enabled" = "yes"
    "path"    = "${local.kv_path}"
    "README"  = "This is used for integration with the `core` module. See https://github.com/GovTechSG/terraform-modules/tree/master/modules/docker-auth"
  }
}
