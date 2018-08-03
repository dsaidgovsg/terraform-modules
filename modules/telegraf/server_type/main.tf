locals {
  prefix = "${var.consul_key_prefix}${var.path}server_types/${var.server_type}/"
}

resource "consul_keys" "enabled" {
  count = "${var.core_integration && var.enabled ? 1 : 0}"

  key {
    path   = "${local.prefix}enabled"
    value  = "yes"
    delete = true
  }
}

resource "consul_keys" "elasticsearch_output_enabled" {
  count = "${var.core_integration && var.enabled && var.output_elastisearch ? 1 : 0}"

  key {
    path   = "${local.prefix}output/elasticsearch/enabled"
    value  = "yes"
    delete = true
  }
}

resource "consul_keys" "elasticsearch_output_service" {
  count = "${var.core_integration && var.enabled && var.output_elastisearch ? 1 : 0}"

  key {
    path   = "${local.prefix}output/elasticsearch/service_name"
    value  = "${var.output_elasticsearch_service_name}"
    delete = true
  }
}
