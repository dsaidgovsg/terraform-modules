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
  count = var.enable_encryption ? 1 : 0

  description             = var.kms_key_description
  deletion_window_in_days = var.kms_key_deletion_window_in_days
  enable_key_rotation     = var.kms_key_enable_rotation
  policy                  = local.kms_key_policy_json
  tags                    = merge(var.kms_additional_tags, var.tags)
}

resource "aws_kms_alias" "encryption" {
  count = var.enable_encryption ? 1 : 0

  name          = local.kms_key_alias
  target_key_id = local.kms_key_id
}

resource "aws_efs_file_system" "default" {
  encrypted  = var.enable_encryption
  kms_key_id = local.kms_key_arn
  tags       = var.tags
}

resource "aws_efs_mount_target" "mounts" {
  count           = length(var.vpc_subnets)
  file_system_id  = aws_efs_file_system.default.id
  subnet_id       = var.vpc_subnets[count.index]
  security_groups = [aws_security_group.efs.id]
}

resource "aws_security_group" "efs" {
  name        = var.security_group_name
  description = var.security_group_description
  vpc_id      = var.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "efs" {
  type = "ingress"

  security_group_id = aws_security_group.efs.id
  from_port         = var.efs_ports["from"]
  to_port           = var.efs_ports["to"]
  protocol          = var.efs_ports["protocol"]

  cidr_blocks = var.allowed_cidr_blocks
}

locals {
  efs_filesystem_root_resource = "arn:aws:elasticfilesystem:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:file-system"

  # timestamp() returns 2018-01-02T23:12:01Z, and colon is not allowed for KMS key alias
  formatted_timestamp = replace(timestamp(), ":", "-")

  # Empty strings if enable_encryption is false
  kms_key_id  = concat(aws_kms_key.encryption.*.key_id, [""])[0]
  kms_key_arn = concat(aws_kms_key.encryption.*.arn, [""])[0]

  kms_key_alias       = coalesce(var.kms_key_alias, "${var.kms_key_alias_prefix}${local.formatted_timestamp}")
  kms_key_policy_json = coalesce(var.kms_key_policy_json, data.aws_iam_policy_document.default.json)
}
