# --------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# --------------------------------------------------------------------------------------------------

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
