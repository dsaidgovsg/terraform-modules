variable "bootstrap" {
  description = "Apply the module in bootstrap mode or not. See README for information."
}

variable "gossip_key" {
  description = "Nomad Serf Gossip key"
}

variable "gossip_path" {
  description = "Path to a KV store to store Nomad's gossip key"
}

variable "pki_path" {
  description = "Path to mount the PKI secrets engine to get certificates for Nomad"
  default     = "nomad_tls"
}

variable "pki_ttl" {
  description = "Default TTL for PKI secrets engine in seconds"
  default     = 31536000
}

variable "pki_max_ttl" {
  description = "Max TTL for the PKI secrets engine in seconds"
  default     = 315360000
}

variable "nomad_server_policy" {
  description = "Name of the policy to allow Nomad servers to retrieve a certificate"
  default     = "nomad_tls_server"
}

variable "nomad_client_policy" {
  description = "Name of the policy to allow Nomad clients to retrieve a certificate"
  default     = "nomad_tls_client"
}

variable "vault_base_url" {
  description = <<EOF
  Base URL where your Vault cluster can be accessed. This is used to configure the CRL and CA
  endpoints. Do not include a trailing slash.
EOF

  default = ["https://vault.service.consul:8200"]
}

variable "intermediate_ca" {
  description = <<EOF
  Configure whether the endpoint should use an intermediate or root CA. We recommend that you use
  an intermediate CA signed by the same root CA used to provision your Vault cluster. This will
  enable easier configur
EOF

  default = false
}

# --------------------------------------------------------------------------------------------------
# CA and certificate settings
# --------------------------------------------------------------------------------------------------

variable "ca_cn" {
  description = "The CN of the CA certificate"
  default     = "Nomad Cluster TLS Authority"
}

variable "ca_san" {
  description = <<EOF
  Specifies the requested Subject Alternative Names, in a comma-delimited list.
  These can be host names or email addresses; they will be parsed into their respective fields.
EOF

  default = ""
}

variable "ca_ip_san" {
  description = "Specifies the requested IP Subject Alternative Names, in a comma-delimited list."
  default     = ""
}

variable "ca_exclude_cn_from_sans" {
  description = <<EOF
If set, the given common_name will not be included in DNS or Email Subject Alternate Names
(as appropriate).
Useful if the CN is not a hostname or email address, but is instead some human-readable identifier.
EOF

  default = true
}

variable "ou" {
  description = <<EOF
Specifies the OU (OrganizationalUnit) values in the subject field of the resulting certificate.
This is a comma-separated string or JSON array.
EOF

  default = ""
}

variable "organization" {
  description = <<EOF
 Specifies the O (Organization) values in the subject field of the resulting certificate.
 This is a comma-separated string or JSON array.
EOF

  default = ""
}

variable "country" {
  description = <<EOF
Specifies the C (Country) values in the subject field of the resulting certificate.
This is a comma-separated string or JSON array.
EOF

  default = []
}

variable "locality" {
  description = <<EOF
Specifies the L (Locality) values in the subject field of the resulting certificate.
This is a comma-separated string or JSON array.
EOF

  default = []
}

variable "province" {
  description = <<EOF
Specifies the ST (Province) values in the subject field of the resulting certificate.
This is a comma-separated string or JSON array.
EOF

  default = []
}

variable "street_address" {
  description = <<EOF
Specifies the Street Address values in the subject field of the resulting certificate.
This is a comma-separated string or JSON array.
EOF

  default = []
}

variable "postal_code" {
  description = <<EOF
Specifies the Postal Code values in the subject field of the resulting certificate.
This is a comma-separated string or JSON array.
EOF

  default = []
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
