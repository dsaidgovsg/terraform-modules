data "aws_iam_policy_document" "es_slow_index_log" {
  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream",
    ]

    resources = ["${aws_cloudwatch_log_group.es_slow_index_log.arn}"]

    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }
  }
}

resource "aws_cloudwatch_log_resource_policy" "es_slow_index_log" {
  policy_document = "${data.aws_iam_policy_document.es_slow_index_log.json}"
  policy_name     = "${var.slow_index_log_name}"
}
