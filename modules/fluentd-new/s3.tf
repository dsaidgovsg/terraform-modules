# S3 bucket for logs long term retention
resource "aws_s3_bucket" "logs" {
  count = var.logs_s3_enabled ? 1 : 0

  bucket = var.logs_s3_bucket_name
  tags   = var.tags

  force_destroy = false

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  lifecycle_rule {
    id      = "LogArchivalTransition"
    enabled = true

    abort_incomplete_multipart_upload_days = var.logs_s3_abort_incomplete_days

    transition {
      days          = var.logs_s3_ia_transition_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.logs_s3_glacier_transition_days
      storage_class = "GLACIER"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

data "aws_iam_policy_document" "logs_s3" {
  count = var.logs_s3_enabled ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "${aws_s3_bucket.logs[0].arn}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.logs[0].arn}/*",
    ]
  }
}

resource "aws_iam_policy" "logs_s3" {
  count = var.logs_s3_enabled ? 1 : 0

  name        = var.logs_s3_policy
  path        = "/"
  description = "IAM Policy to store logs in the archival S3 bucket"

  policy = data.aws_iam_policy_document.logs_s3[0].json
}
