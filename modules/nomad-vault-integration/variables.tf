# --------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# --------------------------------------------------------------------------------------------------
variable "nomad_server_iam_role_arn" {
  description = "IAM Role ARN for Nomad servers"
}

# --------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# --------------------------------------------------------------------------------------------------
variable "nomad_server_policy" {
  description = "Name of the policy for Nomad servers"
  default     = "nomad-server"
}

variable "nomad_token_role" {
  description = "Name for the Token role that is used by the Nomad server to create tokens"
  default     = "nomad-cluster"
}

variable "nomad_token_suffix" {
  description = "Suffix to create tokens with. See https://www.vaultproject.io/api/auth/token/index.html#path_suffix for more information"
  default     = "nomad-cluster"
}

variable "disallowed_policies" {
  description = "Additional policies that tokens created by Nomad servers are not allowed to have"
  default     = []
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

variable "allow_unauthenticated" {
  description = <<EOF
        Specifies if users submitting jobs to the Nomad server should be required to provide
        their own Vault token, proving they have access to the policies listed in the job.
        This option should be disabled in an untrusted environment.
EOF

  default = "false"
}
