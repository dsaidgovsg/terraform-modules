variable "server_type" {
  description = "Server type"
}

variable "enabled" {
  description = "Enable Telegraf for this server type"
  default     = true
}

variable "output_elastisearch" {
  description = "Enable metrics output to Elasticsearch"
  default     = false
}

variable "output_elasticsearch_service_name" {
  description = "Service name in Consul to lookup Elasticsearch URLs"
  default     = "elasticsearch"
}

variable "output_prometheus" {
  description = "Create a Prometheus Client to serve the metrics for a Prometheus server to scrape"
  default     = false
}

variable "output_prometheus_service_name" {
  description = "Name of the service to advertise in Consul"
  default     = "prometheus-client"
}

variable "output_prometheus_service_port" {
  description = "Port of the Prometheus Client"
  default     = 9273
}

variable "output_prometheus_service_cidrs" {
  description = "List of CIDRs that the Prometheus client will permit scraping. Remember to allow 127.0.0.1/32 for Consul health checks."
  type        = list(string)

  default = ["0.0.0.0/0"]
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

variable "path" {
  description = "Path after `consul_key_prefix` to write keys to"
  default     = "telegraf/"
}
