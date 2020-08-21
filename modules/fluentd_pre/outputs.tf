output "s3_policy_arn" {
  value = aws_iam_policy.logs_s3_new[0].arn
}
