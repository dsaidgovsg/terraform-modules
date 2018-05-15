# --------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# --------------------------------------------------------------------------------------------------

variable "ssh_user" {
  description = "SSH user to allow SSH access"
  default     = "ubuntu"
}

variable "ttl" {
  description = "TTL for the certificate in seconds"
  default     = 300
}

variable "max_ttl" {
  description = "Max TTL for certificate renewal"
  default     = 86400
}

# --------------------------------------------------------------------------------------------------
# CORE INTEGRATION SETTINGS
# --------------------------------------------------------------------------------------------------
variable "consul_key_prefix" {
  description = <<EOF
        Path prefix to the key in Consul to set for the `core` module to know that this module has
        been applied. If you change this, you have to update the
        `nomad_vault_integration_consul_prefix` variable in the core module as well.
EOF

  default = "terraform/"
}

variable "role_name" {
  description = <<EOF
    Name of role for each of the types of instances.
EOF

  default = "default"
}

variable "consul_enable" {
  description = <<EOF
    Enable SSH Certificate signing on Consul servers. The Consul servers will also install the CA
    from Vault automatically.
EOF

  default = true
}

variable "consul_path" {
  description = "Path for Consul servers SSH access"
  default     = "ssh_consul"
}

variable "vault_enable" {
  description = <<EOF
    Enable SSH Certificate signing on Vault servers. The Vault servers will also install the CA
    from Vault automatically.
EOF

  default = true
}

variable "vault_path" {
  description = "Path for Vault servers SSH access"
  default     = "ssh_vault"
}

variable "nomad_server_enable" {
  description = <<EOF
    Enable SSH Certificate signing on Nomad servers. The Nomad servers will also install the CA
    from Vault automatically.
EOF

  default = true
}

variable "nomad_server_path" {
  description = "Path for Nomad servers SSH access"
  default     = "ssh_nomad_server"
}

variable "nomad_client_enable" {
  description = <<EOF
    Enable SSH Certificate signing on Nomad clients. The Nomad clients will also install the CA
    from Vault automatically.
EOF

  default = true
}

variable "nomad_client_path" {
  description = "Path for Nomad clients SSH access"
  default     = "ssh_nomad_client"
}
