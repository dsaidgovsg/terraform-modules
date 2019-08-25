output "id" {
  description = "ID of EFS"
  value       = "${aws_efs_file_system.default.id}"
}

output "arn" {
  description = "ARN of EFS"
  value       = "${aws_efs_file_system.default.arn}"
}

output "dns_name" {
  description = "DNS name of EFS"
  value       = "${aws_efs_file_system.default.dns_name}"
}

output "mount_target_ids" {
  description = "Mount target IDs of EFS. The order of elements is the same as the order of the given vpc_subnets."
  value       = "${aws_efs_mount_target.mounts.*.id}"
}

output "mount_target_dns_names" {
  description = "Mount target DNS names of EFS. The order of elements is the same as the order of the given vpc_subnets."
  value       = "${aws_efs_mount_target.mounts.*.dns_name}"
}

output "security_group_name" {
  description = "Name of the EFS security group"
  value       = "${aws_security_group.efs.name}"
}

output "security_group_arn" {
  description = "ARN of the EFS security group"
  value       = "${aws_security_group.efs.arn}"
}

output "security_group_id" {
  description = "ID of the EFS security group"
  value       = "${aws_security_group.efs.id}"
}

output "root_resource" {
  description = "ARN of EFS resource at root"
  value       = "${local.efs_filesystem_root_resource}"
}

output "kms_key_alias" {
  description = "KMS key alias used for EFS encryption"
  value       = "${local.kms_key_alias}"
}

output "kms_key_arn" {
  description = "ARN of KMS key used for EFS encryption"
  value       = "${local.kms_key_arn}"
}

output "kms_key_key_id" {
  description = "Key ID of KMS key used for EFS encryption"
  value       = "${local.kms_key_id}"
}
