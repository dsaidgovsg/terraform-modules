resource "vault_generic_secret" "gossip" {
  path = "${var.gossip_path}"

  data_json = <<EOF
{
  "key": "${var.gossip_key}"
}
EOF
}
