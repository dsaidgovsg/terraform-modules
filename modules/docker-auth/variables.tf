variable "registries" {
  description = <<EOF
A map of registries where the key is the URL of the registry and the value is of the form
`<username>:<password>` base64 encoded.

For example, on the shell, you can use the command `echo -n '<username>:<password>' | base64 -w0`
to get the output required
EOF

  type = map(string)
}

# --------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# --------------------------------------------------------------------------------------------------
variable "kv_path" {
  description = "Path to the KV store"
  default     = "secret"
}

variable "kv_subpath" {
  description = "Subpath inside the KV store to store the authentication"
  default     = "terraform/docker-auth"
}

variable "policy_name" {
  description = "Name of the policy to allow for access to Docker registries"
  default     = "docker-auth"
}

variable "provision_kv_store" {
  description = "If you have not enabled a KV store for Vault, set this to `true` to provision one"
  default     = false
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
