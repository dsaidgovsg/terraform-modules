###################################################################################################
# Defines Traefik Configuration in Consul
###################################################################################################

locals {
  consul_port    = "8500"
  consul_service = "consul.service.consul:${local.consul_port}"
  api_entrypoint = "api"
}

# [entrypoints] section
resource "consul_keys" "entrypoints_http" {
  key {
    path  = "${var.traefik_consul_prefix}/entrypoints/http/address"
    value = ":80"
  }
}

resource "consul_keys" "entrypoints_internal" {
  key {
    path  = "${var.traefik_consul_prefix}/entrypoints/internal/address"
    value = ":81"
  }
}

resource "consul_keys" "entrypoints_api" {
  key {
    path  = "${var.traefik_consul_prefix}/entrypoints/${local.api_entrypoint}/address"
    value = ":8080"
  }
}

# [consulCatalog] section

resource "consul_keys" "consulcatalog_endpoint" {
  key {
    path  = "${var.traefik_consul_prefix}/consulcatalog/endpoint"
    value = "${local.consul_service}"
  }
}

resource "consul_keys" "consulcatalog_domain" {
  key {
    path  = "${var.traefik_consul_prefix}/consulcatalog/domain"
    value = "consul.localhost"
  }
}

resource "consul_keys" "consulcatalog_exposedbydefault" {
  key {
    path  = "${var.traefik_consul_prefix}/consulcatalog/exposedbydefault"
    value = "false"
  }
}

resource "consul_keys" "consulcatalog_prefix" {
  key {
    path  = "${var.traefik_consul_prefix}/consulcatalog/prefix"
    value = "${var.traefik_consul_catalog_prefix}"
  }
}

# [api] section
resource "consul_keys" "api_entrypoint" {
  key {
    path  = "${var.traefik_consul_prefix}/api/entrypoint"
    value = "${local.api_entrypoint}"
  }
}

resource "consul_keys" "api_dashboard" {
  key {
    path  = "${var.traefik_consul_prefix}/api/dashboard"
    value = "true"
  }
}

# [ping] section

resource "consul_keys" "ping_entrypoint" {
  key {
    path  = "${var.traefik_consul_prefix}/ping/entrypoint"
    value = "${local.api_entrypoint}"
  }
}

# [traefikLog] section
resource "consul_keys" "traefiklog_filepath" {
  key {
    path  = "${var.traefik_consul_prefix}/traefiklog/filepath"
    value = "/dev/stderr"
  }
}

resource "consul_keys" "traefiklog_format" {
  count = "${var.log_json ? 1 : 0}"

  key {
    path  = "${var.traefik_consul_prefix}/traefiklog/format"
    value = "json"
  }
}

# [accessLog] section
resource "consul_keys" "accesslog_filepath" {
  count = "${var.access_log_enable ? 1 : 0}"

  key {
    path  = "${var.traefik_consul_prefix}/accesslog/filepath"
    value = "/dev/stdout"
  }
}

resource "consul_keys" "accesslog_format" {
  count = "${var.access_log_enable && var.access_log_json ? 1 : 0}"

  key {
    path  = "${var.traefik_consul_prefix}/accesslog/format"
    value = "json"
  }
}
