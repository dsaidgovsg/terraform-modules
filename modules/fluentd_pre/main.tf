provider "template" {
  # See: https://github.com/terraform-providers/terraform-provider-template/blob/v2.0.0/CHANGELOG.md#200-january-14-2019
  # Need to pin the minimum version for templates/fluent.conf
  version = "~> 2.0"
}

locals {
  file_logging_consul_key  = "${var.consul_key_prefix}fluentd/log_to_file"
  fluentd_match_consul_key = "${var.consul_key_prefix}fluentd/match"
  s3_consul_key            = "${var.consul_key_prefix}fluentd/log_to_s3"
  inject_source_host       = "${var.consul_key_prefix}fluentd/inject_source_host"
  source_address_key       = "${var.consul_key_prefix}fluentd/source_address_key"
  source_hostname_key      = "${var.consul_key_prefix}fluentd/source_hostname_key"
}

data "template_file" "fluentd_conf" {
  template = file("${path.module}/templates/fluent.conf")

  vars = {
    elasticsearch_host = var.elasticsearch_host
    elasticsearch_port = var.elasticsearch_port

    fluentd_port = 4224
    es6_support  = false

    s3_bucket     = aws_s3_bucket.logs[0].id
    s3_region     = "ap-southeast-1"
    s3_prefix     = "logs/"
    storage_class = var.logs_s3_storage_class

    file_logging_consul_key  = local.file_logging_consul_key
    fluentd_match_consul_key = local.fluentd_match_consul_key
    s3_consul_key            = local.s3_consul_key

    inject_source_host  = local.inject_source_host
    source_address_key  = local.source_address_key
    source_hostname_key = local.source_hostname_key
  }
}

resource "local_file" "fluentd_rendered_conf" {
  content  = data.template_file.fluentd_conf.rendered
  filename = "${var.artifacts_base_path}/rendered/fluent.conf"
}
