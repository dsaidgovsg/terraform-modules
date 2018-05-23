# --------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# --------------------------------------------------------------------------------------------------
variable "vault_iam_role_id" {
  description = "Vault IAM role ID to apply the policy to"
}

variable "consul_iam_role_arn" {
  description = "ARN of the IAM role for Consul servers"
}

variable "nomad_server_iam_role_arn" {
  description = "ARN of the IAM role for Nomad servers"
}

variable "nomad_client_iam_role_arn" {
  description = "ARN of the IAM role for Nomad clients"
}

variable "vault_iam_role_arn" {
  description = "ARN of the IAM role for Vault servers"
}

# --------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# --------------------------------------------------------------------------------------------------
variable "aws_auth_path" {
  description = "Path to enable the AWS authentication method on"
  default     = "aws"
}

variable "iam_policy_name" {
  description = "Name of the IAM policy to allow Vault servers to authenticate with AWS"
  default     = "VaultAwsAuth"
}

variable "base_policies" {
  description = "List of policies to assign to all tokens created via the AWS authentication method"
  default     = []
}

variable "consul_role" {
  description = "Name of the AWS authentication role for Consul servers"
  default     = "consul"
}

variable "consul_policies" {
  description = "Policies to attach to Consul servers role"
  default     = []
}

variable "nomad_server_role" {
  description = "Name of the AWS authentication role for Nomad servers"
  default     = "nomad-server"
}

variable "nomad_server_policies" {
  description = "Policies to attach to Nomad servers role"
  default     = []
}

variable "nomad_client_role" {
  description = "Name of the AWS authentication role for Nomad clients"
  default     = "nomad-client"
}

variable "nomad_client_policies" {
  description = "Policies to attach to Nomad clients role"
  default     = []
}

variable "vault_role" {
  description = "Name of the AWS authentication role for Vault servers"
  default     = "vault"
}

variable "vault_policies" {
  description = "Policies to attach to Vault servers role"
  default     = []
}

variable "period_minutes" {
  description = <<EOF
The token should be renewed within the duration specified by this value.
At each renewal, the token's TTL will be set to the value of this field.
The maximum allowed lifetime of token issued using this role. Specified as a number of minutes.
EOF

  default = 4320
}

# --------------------------------------------------------------------------------------------------
# CORE INTEGRATION SETTINGS
# --------------------------------------------------------------------------------------------------
variable "core_integration" {
  description = <<EOF
        Enable integration with the `core` module by setting some values in Consul so
        that the user_data scripts in core know that this module has been applied
EOF

  default = true
}

variable "consul_key_prefix" {
  description = <<EOF
        Path prefix to the key in Consul to set for the `core` module to know that this module has
        been applied. If you change this, you have to update the
        `integration_consul_prefix` variable in the core module as well.
EOF

  default = "terraform/"
}
