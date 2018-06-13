variable "consul_enabled" {
  description = "Enable td-agent for Consul servers"
  default     = true
}

variable "nomad_server_enabled" {
  description = "Enable td-agent for Nomad servers"
  default     = true
}

variable "nomad_client_enabled" {
  description = "Enable td-agent for Nomad clients"
  default     = true
}

variable "vault_enabled" {
  description = "Enable td-agent for Vault servers"
  default     = true
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
