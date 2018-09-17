output "jobspec" {
  description = "Rendered jobspec"
  value       = "${data.template_file.fluentd_jobspec.rendered}"
}

output "s3_arn" {
  description = "ARN of the S3 bucket created"
  value       = "${var.logs_s3_enabled ? aws_s3_bucket.logs.arn : ""}"
}

output "s3_iam_arn" {
  description = "ARN of the IAM Policy document for S3 access"
  value       = "${var.logs_s3_enabled ? aws_iam_policy.logs_s3.arn : ""}"
}
