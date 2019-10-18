#
# Security and VPC related
#

variable "vpc_id" {
  description = "ID of VPC to add the security group for the EFS setup"
}

variable "vpc_subnets" {
  description = "IDs of VPC subnets to add the mount targets in"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks to allow EFS port access into the security group"
  type        = list(string)
}

variable "security_group_name" {
  description = "Name of security group for EFS. Empty string to use a random name."
  default     = ""
}

variable "security_group_description" {
  description = "Description of security group for EFS"
  default     = "Security group for EFS"
}

#
# EFS related
#

variable "enable_encryption" {
  description = "Boolean to specify whether to enable KMS encryption for EFS"
  default     = true
}

variable "kms_additional_tags" {
  description = "KMS key additional tags for EFS"
  default     = {}
}

variable "kms_key_description" {
  description = "Description to use for KMS key"
  default     = "Encryption key for EFS"
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

variable "kms_key_deletion_window_in_days" {
  description = <<EOF
Duration in days after which the key is deleted after destruction of the resource,
must be between 7 and 30 days
EOF

  default = 30
}

variable "kms_key_enable_rotation" {
  description = "Specifies whether key rotation is enabled"
  default     = true
}

variable "kms_key_policy_json" {
  description = "JSON content of IAM policy to attach to the KMS key. Empty string to use root identifier as principal for all KMS actions."
  default     = ""
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

  default = {
    Terraform = "true"
  }
}
