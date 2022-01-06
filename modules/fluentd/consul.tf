locals {
  weekly_index_enabled_consul_key = "${var.consul_key_prefix}fluentd/weekly_index_enabled"
  file_logging_consul_key         = "${var.consul_key_prefix}fluentd/log_to_file"
  fluentd_match_consul_key        = "${var.consul_key_prefix}fluentd/match"
  s3_consul_key                   = "${var.consul_key_prefix}fluentd/log_to_s3"
  inject_source_host              = "${var.consul_key_prefix}fluentd/inject_source_host"
  source_address_key              = "${var.consul_key_prefix}fluentd/source_address_key"
  source_hostname_key             = "${var.consul_key_prefix}fluentd/source_hostname_key"
}

resource "consul_keys" "readme" {
  key {
    path = "${var.consul_key_prefix}fluentd/README"

    value = <<EOF
This is used for integration with the `core` module.
See https://github.com/GovTechSG/terraform-modules/tree/master/modules/fluentd
EOF

    delete = true
  }
}

resource "consul_keys" "log_to_file" {
  key {
    path   = local.file_logging_consul_key
    value  = var.enable_file_logging
    delete = true
  }
}

resource "consul_keys" "consul_keys_match" {
  key {
    path   = local.fluentd_match_consul_key
    value  = var.fluentd_match
    delete = true
  }
}

resource "consul_keys" "log_to_s3" {
  key {
    path   = local.s3_consul_key
    value  = var.logs_s3_enabled ? "true" : "false"
    delete = true
  }
}

resource "consul_keys" "inject_source_host" {
  key {
    path   = local.inject_source_host
    value  = var.inject_source_host ? "true" : "false"
    delete = true
  }
}

resource "consul_keys" "source_address_key" {
  key {
    path   = local.source_address_key
    value  = var.inject_source_host ? var.source_address_key : ""
    delete = true
  }
}

resource "consul_keys" "source_hostname_key" {
  key {
    path   = local.source_hostname_key
    value  = var.inject_source_host ? var.source_hostname_key : ""
    delete = true
  }
}

resource "consul_keys" "weekly_index_enabled" {
  key {
    path   = local.weekly_index_enabled_consul_key
    value  = var.weekly_index_enabled ? "true" : "false"
    delete = true
  }
}
