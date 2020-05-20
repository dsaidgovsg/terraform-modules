provider "template" {
  # See: https://github.com/terraform-providers/terraform-provider-template/blob/v2.0.0/CHANGELOG.md#200-january-14-2019
  # Need to pin the minimum version for templates/fluent.conf
  version = "~> 2.0"
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
  }
}

resource "local_file" "fluentd_rendered_conf" {
  content  = data.template_file.fluentd_conf.rendered
  filename = "${var.artifacts_base_path}/rendered/fluent.conf"
}
