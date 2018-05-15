################################################
# Sanity check that the Bootstrap Consul key is set
################################################
data "consul_keys" "enabled" {
  key {
    name = "enabled"
    path = "${var.consul_key_prefix}/nomad-acl/enabled"
  }
}

locals {
  enabled = "${data.consul_keys.enabled.var.enabled == "yes" ? 1 : 0}"
}

resource "nomad_acl_token" "management" {
  count = "${local.enabled}"

  name = "Vault Management Token at path `${var.path}`"
  type = "management"
}

resource "vault_mount" "nomad" {
  count = "${local.enabled}"

  path = "${var.path}"
  type = "nomad"

  description = "Nomad ACL token"
}

data "template_file" "vault_configuration" {
  template = <<EOF
{
    "address": "$${address}",
    "token": "$${token}"
}
EOF

  vars {
    token   = "${nomad_acl_token.management.secret_id}"
    address = "${var.nomad_address}"
  }
}

resource "vault_generic_secret" "nomad_configuration" {
  count = "${local.enabled}"

  path      = "${var.path}/config/access"
  data_json = "${data.template_file.vault_configuration.rendered}"
}
