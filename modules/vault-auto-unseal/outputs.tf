output "kms_key_arn" {
  description = "ARN of the KMS CMK provisioned"
  value       = "${aws_kms_alias.vault_unseal.arn}"
}

output "vpce_kms_dns_name" {
  description = "DNS name for the KMS VPC Endpoint"
  value       = "${var.enable_kms_vpce ? lookup(aws_vpc_endpoint.kms.dns_entry[0], "dns_name"): ""}"
}

output "vpce_kms_subnets" {
  description = "List of subnets where the KMS VPC Endpoint was provisioned"
  value       = "${local.kms_vpce_subnets}"
}
