output "id" {
  description = "ID of the setup EFS"
  value       = "${aws_efs_file_system.default.id}"
}

output "dns_name" {
  description = "DNS name of EFS"
  value       = "${aws_efs_file_system.default.dns_name}"
}

output "root_resource" {
  description = "ARN of EFS resource at root"
  value       = "${local.efs_filesystem_root_resource}"
}

output "kms_key_alias" {
  description = "KMS key alias used for encryption"
  value       = "${local.kms_key_alias}"
}
