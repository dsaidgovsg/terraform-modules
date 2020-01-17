output "kms_key_arn" {
  description = "ARN of the KMS CMK provisioned"
  value       = aws_kms_key.vault_unseal.arn
}

locals {
  dns_entries = aws_vpc_endpoint.kms.*.dns_entry
  dns_entry   = local.dns_entries[0]
}

output "vpce_kms_dns_name" {
  description = "DNS name for the KMS VPC Endpoint"
  value       = var.enable_kms_vpce ? lookup(local.dns_entry[0], "dns_name") : ""
}

output "vpce_kms_subnets" {
  description = "List of subnets where the KMS VPC Endpoint was provisioned"
  value       = local.kms_vpce_subnets
}

output "vpce_kms_security_group" {
  description = "ID of the security group created for the VPC endpoint"
  value       = var.enable_kms_vpce ? aws_security_group.kms_vpce.id : ""
}
