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
