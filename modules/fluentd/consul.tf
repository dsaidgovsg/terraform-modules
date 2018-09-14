locals {
  file_logging_consul_key  = "${var.consul_key_prefix}fluentd/log_to_file"
  fluentd_match_consul_key = "${var.consul_key_prefix}fluentd/match"
  s3_consul_key            = "${var.consul_key_prefix}fluentd/log_to_s3"
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
    path  = "${local.file_logging_consul_key}"
    value = "${var.enable_file_logging}"
  }
}

resource "consul_keys" "consul_keys_match" {
  key {
    path  = "${local.fluentd_match_consul_key}"
    value = "${var.fluentd_match}"
  }
}

resource "consul_keys" "log_to_s3" {
  key {
    path  = "${local.s3_consul_key}"
    value = "${var.logs_s3_enabled ? "true" : "false"}"
  }
}
