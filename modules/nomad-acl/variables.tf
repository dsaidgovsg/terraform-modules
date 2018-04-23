# --------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# --------------------------------------------------------------------------------------------------

variable "nomad_address" {
    description = "FQDN of Nomad addresses to access. Include the port and protocol"
    default = "http://nomad.service.consul:4646"
}

variable "path" {
    description = "Path to enable the Nomad secrets engine on Vault"
    default = "nomad"
}

# --------------------------------------------------------------------------------------------------
# CORE INTEGRATION SETTINGS
# --------------------------------------------------------------------------------------------------
variable "consul_key_prefix" {
    description = <<EOF
        Path prefix to the key in Consul to set for the `core` module to know that this module has
        been applied. If you change this, you have to update the
        `nomad_acl_consul_prefix` variable in the core module as well.
EOF
    default = "terraform/"
}
