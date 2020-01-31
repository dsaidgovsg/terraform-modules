variable "kms_key_alias" {
  description = "Alias to apply to the KMS key. Must begin with `alias/`"
  default     = "alias/vault_auto_unseal"
}

variable "enable_kms_vpce" {
  description = "Enable provisioning a VPC Endpoint for KMS"
  default     = false
}

variable "vpce_subnets" {
  description = "List of subnets to provision the VPC Endpoint in. The Autoscaling group for Vault must be configured to use the same subnets that the VPC Endpoint are provisioned in. Note that because the KMS VPCE might not be supported in all the Availability Zones, you should use the output from the module to provide the list of subnets for your Vault ASG."
  type        = list(string)
  default     = []
}

variable "vpce_subnets_count" {
  description = "Number of subnets provided in `vpce_subnets`"
  default     = 0
}

variable "vpc_id" {
  description = "ID of the VPC to provision the endpoints in"
  default     = ""
}

variable "vpce_sg_name" {
  description = "Name of the security group to provision for the KMS VPC Endpoint"
  default     = "KMS VPC Endpoint"
}

variable "tags" {
  description = "Tags to apply to resources that support it"

  default = {
    Terraform = "true"
  }
}
