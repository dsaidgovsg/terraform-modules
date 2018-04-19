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
variable "aws_auth_path" {
    description = "Path to enable the AWS authentication method on"
    default = "aws"
}

variable "nomad_server_policy" {
    description = "Name of the policy for Nomad servers"
    default = "nomad-server"
}

variable "nomad_aws_token_role" {
    description = "Name of the token role that is used to authenticate Nomad servers with the AWS authentication"
    default = "nomad-server"
}

variable "nomad_token_role" {
    description = "Name for the Token role that is used by the Nomad server to create tokens"
    default = "nomad-cluster"
}

variable "create_iam_policy" {
    description = "Enable this module to create the appropriate IAM policy for your Vault instances"
    default = false
}

variable "iam_role_name" {
    description = "If `create_iam_policy` is enabled, this will be the name of the policy created"
    default = "VaultAwsAuth"
}

variable "vault_iam_role_id" {
    description = "If `create_iam_policy` is enabled, this will be the Vault IAM role ID to apply the policy to"
    default = ""
}

# --------------------------------------------------------------------------------------------------
# CORE INTEGRATION SETTINGS
# --------------------------------------------------------------------------------------------------
variable "core_integration" {
    description = "Enable integration with the `core` module by setting some values in Consul so that the user_data scripts in core know that this module has been applied"
    default = true
}

variable "consul_key_prefix" {
    description = "Path prefix to the key in Consul to set for the `core` module to know that this module has been applied."
    default = "terraform/nomad-vault-integration/"
}

variable "allow_unauthenticated" {
    description = "Specifies if users submitting jobs to the Nomad server should be required to provide their own Vault token, proving they have access to the policies listed in the job. This option should be disabled in an untrusted environment."
    default = "false"
}
