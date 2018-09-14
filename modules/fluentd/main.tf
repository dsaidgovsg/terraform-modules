data "consul_catalog_service" "elasticsearch" {
  name = "${var.elasticsearch_consul_name}"
}

data "template_file" "fluentd_tf_rendered_conf" {
  template = "${file("${path.module}/templates/fluent.conf")}"

  vars {
    elasticsearch_hostname = "${var.elasticsearch_hostname}"
    elasticsearch_port     = "${var.elasticsearch_port}"
    fluentd_port           = "${var.fluentd_port}"

    es6_support = "${var.es6_support}"

    s3_bucket     = "${aws_s3_bucket.logs.id}"
    s3_region     = "${var.aws_region}"
    s3_prefix     = "logs/"
    storage_class = "${var.logs_s3_storage_class}"

    file_logging_consul_key  = "${local.file_logging_consul_key}"
    fluentd_match_consul_key = "${local.fluentd_match_consul_key}"
    s3_consul_key            = "${local.s3_consul_key}"
  }
}

data "aws_availability_zones" "available" {}

data "template_file" "fluentd_jobspec" {
  template = "${file("${path.module}/templates/fluentd.nomad")}"

  vars {
    region = "${var.aws_region}"
    az     = "${jsonencode(coalescelist(var.nomad_azs, data.aws_availability_zones.available.names))}"

    node_class_operator = "${var.node_class_operator}"
    node_class          = "${var.node_class}"

    fluentd_count      = "${var.fluentd_count}"
    fluentd_port       = "${var.fluentd_port}"
    fluentd_image      = "${var.fluentd_image}"
    fluentd_tag        = "${var.fluentd_tag}"
    fluentd_force_pull = "${var.fluentd_force_pull}"

    fluentd_conf_template = "${data.template_file.fluentd_tf_rendered_conf.rendered}"
    fluentd_conf_file     = "${var.fluentd_conf_file}"

    vault_policy = "${vault_policy.logs.name}"
    aws_path     = "${local.aws_creds_path}"
  }
}

resource "nomad_job" "fluentd" {
  jobspec = "${data.template_file.fluentd_jobspec.rendered}"
}
