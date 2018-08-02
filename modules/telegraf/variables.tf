variable "consul_enabled" {
  description = "Enable Telegraf for Consul servers"
  default     = true
}

variable "consul_output_elastisearch" {
  description = "Enable metrics output to Elasticsearch"
  default     = false
}

variable "consul_output_elasticsearch_service_name" {
  description = "Service name in Consul to lookup Elasticsearch URLs"
  default     = "elasticsearch"
}

variable "nomad_server_enabled" {
  description = "Enable Telegraf for Nomad servers"
  default     = true
}

variable "nomad_server_output_elastisearch" {
  description = "Enable metrics output to Elasticsearch"
  default     = false
}

variable "nomad_server_output_elasticsearch_service_name" {
  description = "Service name in Consul to lookup Elasticsearch URLs"
  default     = "elasticsearch"
}

variable "nomad_client_enabled" {
  description = "Enable Telegraf for Nomad clients"
  default     = true
}

variable "nomad_client_output_elastisearch" {
  description = "Enable metrics output to Elasticsearch"
  default     = false
}

variable "nomad_client_output_elasticsearch_service_name" {
  description = "Service name in Consul to lookup Elasticsearch URLs"
  default     = "elasticsearch"
}

variable "vault_enabled" {
  description = "Enable Telegraf for Vault servers"
  default     = true
}

variable "vault_output_elastisearch" {
  description = "Enable metrics output to Elasticsearch"
  default     = false
}

variable "vault_output_elasticsearch_service_name" {
  description = "Service name in Consul to lookup Elasticsearch URLs"
  default     = "elasticsearch"
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
