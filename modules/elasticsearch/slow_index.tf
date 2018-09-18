resource "aws_cloudwatch_log_group" "es_slow_index_log" {
  count = "${var.enable_slow_index_log ? 1 : 0}"

  name              = "${var.slow_index_log_name}"
  retention_in_days = "${var.slow_index_log_retention}"
  tags              = "${merge(var.slow_index_additional_tags, map("Name", format("%s", var.slow_index_log_name)))}"
}

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
  count = "${var.enable_slow_index_log ? 1 : 0}"

  policy_document = "${data.aws_iam_policy_document.es_slow_index_log.json}"
  policy_name     = "${var.slow_index_log_name}"
}
