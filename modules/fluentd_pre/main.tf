data "template_file" "fluentd_conf" {
  template = file("${path.module}/templates/fluent.conf")

  vars = {
    elasticsearch_host = var.elasticsearch_host
    elasticsearch_port = var.elasticsearch_port

    fluentd_port  = var.fluentd_port
    fluentd_match = var.fluentd_match

    s3_bucket                = aws_s3_bucket.logs[0].id
    s3_region                = "ap-southeast-1"
    s3_prefix                = "logs/"
    storage_class            = var.logs_s3_storage_class
    logs_s3_enabled          = var.logs_s3_enabled
    logs_local_store_enabled = var.logs_local_store_enabled
  }
}

resource "local_file" "fluentd_rendered_conf" {
  content  = data.template_file.fluentd_conf.rendered
  filename = "${var.artifacts_base_path}/rendered/fluent.conf"
}
