resource "consul_keys" "core_integration" {
  count = "${var.core_integration ? 1 : 0}"

  key {
    path = "${var.consul_key_prefix}td-agent/README"
    delete = true

    value = <<EOF
This is used for integration with the `core` module.
See https://github.com/GovTechSG/terraform-modules/tree/master/modules/td-agent
EOF
  }
}

resource "consul_keys" "consul" {
  count = "${var.core_integration && var.consul_enabled ? 1 : 0}"

  key {
    path  = "${var.consul_key_prefix}td-agent/consul/enabled"
    value = "yes"
    delete = true
  }
}

resource "consul_keys" "nomad_server" {
  count = "${var.core_integration && var.nomad_server_enabled ? 1 : 0}"

  key {
    path  = "${var.consul_key_prefix}td-agent/nomad_server/enabled"
    value = "yes"
    delete = true
  }
}

resource "consul_keys" "nomad_client" {
  count = "${var.core_integration && var.nomad_client_enabled ? 1 : 0}"

  key {
    path  = "${var.consul_key_prefix}td-agent/nomad_client/enabled"
    value = "yes"
    delete = true
  }
}

resource "consul_keys" "vault" {
  count = "${var.core_integration && var.vault_enabled ? 1 : 0}"

  key {
    path  = "${var.consul_key_prefix}td-agent/vault/enabled"
    value = "yes"
    delete = true
  }
}
