resource "vault_mount" "pki" {
  path        = "${var.pki_path}"
  type        = "pki"
  description = "Certificate generator for Nomad cluster TLS communication"

  default_lease_ttl_seconds = "${var.pki_ttl}"
  max_lease_ttl_seconds     = "${var.pki_max_ttl}"
}

locals {
  ca_endpoints       = "${jsonencode(sort(formatlist("%s/%s/ca", var.vault_base_url, vault_mount.pki.path)))}"
  ca_chain_endpoints = "${jsonencode(sort(formatlist("%s/%s/ca_chain", var.vault_base_url, vault_mount.pki.path)))}"

  crl_distribution_points = "${jsonencode(sort(formatlist("%s/%s/crl", var.vault_base_url, vault_mount.pki.path)))}"
}

resource "vault_generic_secret" "pki_config" {
  path = "${vault_mount.pki.path}/config/urls"

  data_json = <<EOF
{
  "issuing_certificates": ${local.ca_endpoints},
  "crl_distribution_points": ${local.crl_distribution_points},
  "ocsp_servers": []
}
EOF
}

################################################
# Mark in Consul for the `core` module scripts to configure themselves
################################################
resource "consul_key_prefix" "core_integration" {
  depends_on = []

  count       = "${var.core_integration ? 1 : 0}"
  path_prefix = "${var.consul_key_prefix}nomad-tls/"

  subkeys {
    enabled     = "yes"
    bootstrap   = "${var.bootstrap}"
    pki_path    = "${vault_mount.pki.path}"
    server_role = "server"
    client_role = "client"
    gossip_path = "${var.gossip_path}"

    README = <<EOF
This is used for integration with the `core` module.
See https://github.com/GovTechSG/terraform-modules/tree/master/modules/nomad-tls
EOF
  }
}
