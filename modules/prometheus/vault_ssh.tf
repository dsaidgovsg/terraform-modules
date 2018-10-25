module "vault_ssh" {
  source = "../vault-ssh/ssh-engine"

  enabled     = "${var.vault_ssh_enabled}"
  path        = "${var.vault_ssh_path}"
  description = "Prometheus Server SSH Access"

  ssh_user  = "${var.vault_ssh_user}"
  ttl       = "${var.vault_ssh_ttl}"
  max_ttl   = "${var.vault_ssh_max_ttl}"
  role_name = "${var.vault_ssh_role_name}"
}

resource "consul_key_prefix" "consul" {
  count      = "${var.vault_ssh_enabled ? 1 : 0}"
  depends_on = ["module.vault_ssh"]

  path_prefix = "${var.consul_key_prefix}vault-ssh/${var.server_type}/"

  subkeys {
    enabled = "yes"
    path    = "${var.vault_ssh_path}"
  }
}
