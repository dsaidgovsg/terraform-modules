#
# Security and VPC related
#

variable "vpc_id" {
  description = "ID of VPC to add the security group for the EFS setup"
}

variable "vpc_subnets" {
  description = "IDs of VPC subnets to add the mount targets in"
  type        = "list"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks to allow EFS port access into the security group"
  type        = "list"
}

variable "security_group_name" {
  description = "Name of security group for EFS. Empty string to use a random name."
  default     = ""
}

#
# EFS related
#

variable "kms_additional_tags" {
  description = "KMS key additional tags for EFS"
  default     = {}
}

variable "kms_key_alias_prefix" {
  description = <<EOF
Alias prefix for the KMS key for EFS. Current timestamp is used as the suffix.
Must prefix with alias/.
kms_key_alias is used instead if specified.
EOF

  default = "alias/efs-default-"
}

variable "kms_key_alias" {
  description = <<EOF
Alias for the KMS key for EFS. Must prefix with alias/.
Overrides kms_key_alias_prefix if this is specified.
EOF

  default = ""
}

variable "efs_ports" {
  description = "Ports to allow access to EFS"

  default = {
    from     = 2049
    to       = 2049
    protocol = "tcp"
  }
}

#
# Others
#

variable "tags" {
  description = "Tags to apply to resources that allow it"

  default {
    Terraform = "true"
  }
}
