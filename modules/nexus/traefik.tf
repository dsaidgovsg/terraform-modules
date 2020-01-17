# Traefik Integration
resource "consul_keys" "traefik_enabled" {
  count = var.traefik_enabled ? 1 : 0

  key {
    path   = "${local.consul_prefix}traefik/enabled"
    value  = "yes"
    delete = true
  }
}

resource "consul_keys" "traefik_fqdns" {
  count = var.traefik_enabled ? 1 : 0

  key {
    path   = "${local.consul_prefix}traefik/fqdns"
    value  = join(",", var.traefik_fqdns)
    delete = true
  }
}

resource "consul_keys" "traefik_entrypoints" {
  count = var.traefik_enabled ? 1 : 0

  key {
    path   = "${local.consul_prefix}traefik/entrypoints"
    value  = join(",", var.traefik_entrypoints)
    delete = true
  }
}
