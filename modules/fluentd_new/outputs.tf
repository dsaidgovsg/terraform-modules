output "security_group_id" {
  description = "Security Group ID for Fluentd servers"
  value       = aws_security_group.lc_security_group.id
}
