resource "aws_security_group" "es" {
  name                   = "${var.security_group_name}"
  description            = "Security group for ${var.security_group_name}"
  vpc_id                 = "${var.security_group_vpc_id}"
  tags                   = "${var.security_group_additional_tags}"
  revoke_rules_on_delete = true
}

resource "aws_security_group_rule" "es_access_rule" {
  type              = "${var.es_default_access["type"]}"
  from_port         = "${var.es_default_access["port"]}"
  to_port           = "${var.es_default_access["port"]}"
  protocol          = "${var.es_default_access["protocol"]}"
  cidr_blocks       = ["${var.es_access_cidr_block}"]
  security_group_id = "${aws_security_group.es.id}"
}

data "aws_iam_policy_document" "es_resource_attached_policy" {
  statement {
    actions = [
      "es:ESHttpDelete",
      "es:ESHttpGet",
      "es:ESHttpHead",
      "es:ESHttpPost",
      "es:ESHttpPut",
    ]

    resources = [
      "${aws_elasticsearch_domain.es.arn}",
      "${aws_elasticsearch_domain.es.arn}/*",
    ]

    principals {
      type = "AWS"

      identifiers = ["${distinct(compact(var.es_http_iam_roles))}"]
    }
  }
}

resource "aws_elasticsearch_domain" "es" {
  domain_name           = "${local.es_domain_name}"
  elasticsearch_version = "${var.es_version}"

  cluster_config {
    instance_type            = "${var.es_instance_type}"
    instance_count           = "${var.es_instance_count}"
    dedicated_master_enabled = "${var.es_instance_count >= 10 ? true : false}"
    dedicated_master_count   = "${var.es_instance_count >= 10 ? 3 : 0}"
    dedicated_master_type    = "${var.es_instance_count >= 10 ? (var.es_master_type != "false" ? var.es_master_type : var.es_instance_type) : ""}"
    zone_awareness_enabled   = "${var.es_zone_awareness}"
  }

  vpc_options {
    security_group_ids = ["${aws_security_group.es.id}"]
    subnet_ids         = ["${var.es_vpc_subnet_ids}"]
  }

  ebs_options {
    ebs_enabled = "${var.es_ebs_volume_size > 0 ? true : false}"
    volume_size = "${var.es_ebs_volume_size}"
    volume_type = "${var.es_ebs_volume_type}"
  }

  snapshot_options {
    automated_snapshot_start_hour = "${var.es_snapshot_start_hour}"
  }

  log_publishing_options {
    log_type                 = "INDEX_SLOW_LOGS"
    enabled                  = "${var.enable_slow_index_log}"
    cloudwatch_log_group_arn = "${local.cloudwatch_log_group_arn}"
  }

  encrypt_at_rest {
    enabled    = "${var.es_encrypt_at_rest}"
    kms_key_id = "${local.es_kms_key_id}"
  }

  tags = "${merge(var.es_additional_tags, map("Domain", format("%s", var.es_domain_name)))}"
}

resource "aws_elasticsearch_domain_policy" "es_resource_attached_policy" {
  domain_name     = "${local.es_domain_name}"
  access_policies = "${data.aws_iam_policy_document.es_resource_attached_policy.json}"
}

locals {
  endpoint       = "${aws_elasticsearch_domain.es.endpoint}"
  es_kms_key_id  = "${var.es_encrypt_at_rest ? var.es_kms_key_id : ""}"
  es_domain_name = "tf-${var.es_domain_name}"

  cloudwatch_log_group_arn = "${element(coalescelist(aws_cloudwatch_log_group.es_slow_index_log.*.arn, list("")), 0)}"
}
