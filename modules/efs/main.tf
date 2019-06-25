data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "default" {
  statement {
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_kms_key" "encryption" {
  description             = "Encryption key for EFS"
  deletion_window_in_days = "${var.kms_key_deletion_window_in_days}"
  enable_key_rotation     = "${var.kms_key_enable_rotation}"
  policy                  = "${local.kms_key_policy_json}"
  tags                    = "${merge(var.kms_additional_tags, var.tags)}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "encryption" {
  name          = "${local.kms_key_alias}"
  target_key_id = "${aws_kms_key.encryption.key_id}"
}

resource "aws_efs_file_system" "default" {
  encrypted  = true
  kms_key_id = "${aws_kms_key.encryption.arn}"
  tags       = "${var.tags}"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_efs_mount_target" "mounts" {
  count           = "${length(var.vpc_subnets)}"
  file_system_id  = "${aws_efs_file_system.default.id}"
  subnet_id       = "${var.vpc_subnets[count.index]}"
  security_groups = ["${aws_security_group.efs.id}"]
}

resource "aws_security_group" "efs" {
  name        = "${var.security_group_name}"
  description = "Security group for EFS"
  vpc_id      = "${var.vpc_id}"

  tags = "${var.tags}"
}

resource "aws_security_group_rule" "efs" {
  type = "ingress"

  security_group_id = "${aws_security_group.efs.id}"
  from_port         = "${var.efs_ports["from"]}"
  to_port           = "${var.efs_ports["to"]}"
  protocol          = "${var.efs_ports["protocol"]}"

  cidr_blocks = ["${var.allowed_cidr_blocks}"]
}

locals {
  efs_filesystem_root_resource = "arn:aws:elasticfilesystem:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:file-system"

  # timestamp() returns 2018-01-02T23:12:01Z, and colon is not allowed for KMS key alias
  formatted_timestamp = "${replace(timestamp(), ":", "-")}"

  kms_key_alias       = "${var.kms_key_alias != "" ? var.kms_key_alias : format("%s%s", var.kms_key_alias_prefix, local.formatted_timestamp)}"
  kms_key_policy_json = "${var.kms_key_policy_json != "" ? var.kms_key_policy_json : data.aws_iam_policy_document.default.json}"
}
