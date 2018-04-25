resource "consul_keys" "readme" {
    key {
        path = "${var.consul_key_prefix}vault-ssh/README"
        value = <<EOF
        This is used for integration with the `core` module.
        See https://github.com/GovTechSG/terraform-modules/tree/master/modules/vault-ssh
EOF
    }
}

#####################################
# Consul Servers
#####################################
module "consul" {
    source = "./ssh-engine"

    enabled = "${var.consul_enable}"
    path = "${var.consul_path}"
    description = "Consul Server"

    ssh_user = "${var.ssh_user}"
    ttl = "${var.ttl}"
    max_ttl = "${var.max_ttl}"
    role_name = "${var.role_name}"
}

resource "consul_key_prefix" "consul" {
    count = "${var.consul_enable ? 1 : 0}"
    depends_on = ["module.consul"]

    path_prefix = "${var.consul_key_prefix}vault-ssh/consul/"

    subkeys {
        enabled = "yes"
        path = "${var.consul_path}"
    }
}

#####################################
# Vault Servers
#####################################
module "vault" {
    source = "./ssh-engine"

    enabled = "${var.vault_enable}"
    path = "${var.vault_path}"
    description = "Vault Server"

    ssh_user = "${var.ssh_user}"
    ttl = "${var.ttl}"
    max_ttl = "${var.max_ttl}"
    role_name = "${var.role_name}"
}

resource "consul_key_prefix" "vault" {
    count = "${var.vault_enable ? 1 : 0}"
    depends_on = ["module.vault"]

    path_prefix = "${var.consul_key_prefix}vault-ssh/vault/"

    subkeys {
        enabled = "yes"
        path = "${var.vault_path}"
    }
}

#####################################
# Nomad Servers
#####################################
module "nomad_server" {
    source = "./ssh-engine"

    enabled = "${var.nomad_server_enable}"
    path = "${var.nomad_server_path}"
    description = "Nomad Server"

    ssh_user = "${var.ssh_user}"
    ttl = "${var.ttl}"
    max_ttl = "${var.max_ttl}"
    role_name = "${var.role_name}"
}

resource "consul_key_prefix" "nomad_server" {
    count = "${var.nomad_server_enable ? 1 : 0}"
    depends_on = ["module.nomad_server"]

    path_prefix = "${var.consul_key_prefix}vault-ssh/nomad_server/"

    subkeys {
        enabled = "yes"
        path = "${var.nomad_server_path}"
    }
}

#####################################
# Nomad Clients
#####################################
module "nomad_client" {
    source = "./ssh-engine"

    enabled = "${var.nomad_client_enable}"
    path = "${var.nomad_client_path}"
    description = "Nomad Client"

    ssh_user = "${var.ssh_user}"
    ttl = "${var.ttl}"
    max_ttl = "${var.max_ttl}"
    role_name = "${var.role_name}"
}

resource "consul_key_prefix" "nomad_client" {
    count = "${var.nomad_client_enable ? 1 : 0}"
    depends_on = ["module.nomad_client"]

    path_prefix = "${var.consul_key_prefix}vault-ssh/nomad_client/"

    subkeys {
        enabled = "yes"
        path = "${var.nomad_client_path}"
    }
}
