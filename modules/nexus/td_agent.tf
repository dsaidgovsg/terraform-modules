resource "consul_keys" "td_agent" {
  count = var.td_agent_enabled ? 1 : 0

  key {
    path   = "${var.consul_key_prefix}td-agent/${var.server_type}/enabled"
    value  = "yes"
    delete = true
  }
}
