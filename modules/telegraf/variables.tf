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

variable "consul_output_prometheus" {
  description = "Create a Prometheus Client to serve the metrics for a Prometheus server to scrape"
  default     = false
}

variable "consul_output_prometheus_service_name" {
  description = "Name of the service to advertise in Consul"
  default     = "prometheus-client"
}

variable "consul_output_prometheus_service_port" {
  description = "Port of the Prometheus Client"
  default     = 9273
}

variable "consul_output_prometheus_service_cidrs" {
  description = "List of CIDRs that the Prometheus client will permit scraping. Remember to allow 127.0.0.1/32 for Consul health checks."
  default     = ["0.0.0.0/0"]
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

variable "nomad_server_output_prometheus" {
  description = "Create a Prometheus Client to serve the metrics for a Prometheus server to scrape"
  default     = false
}

variable "nomad_server_output_prometheus_service_name" {
  description = "Name of the service to advertise in Consul"
  default     = "prometheus-client"
}

variable "nomad_server_output_prometheus_service_port" {
  description = "Port of the Prometheus Client"
  default     = 9273
}

variable "nomad_server_output_prometheus_service_cidrs" {
  description = "List of CIDRs that the Prometheus client will permit scraping. Remember to allow 127.0.0.1/32 for Consul health checks."
  default     = ["0.0.0.0/0"]
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

variable "nomad_client_output_prometheus" {
  description = "Create a Prometheus Client to serve the metrics for a Prometheus server to scrape"
  default     = false
}

variable "nomad_client_output_prometheus_service_name" {
  description = "Name of the service to advertise in Consul"
  default     = "prometheus-client"
}

variable "nomad_client_output_prometheus_service_port" {
  description = "Port of the Prometheus Client"
  default     = 9273
}

variable "nomad_client_output_prometheus_service_cidrs" {
  description = "List of CIDRs that the Prometheus client will permit scraping. Remember to allow 127.0.0.1/32 for Consul health checks."
  default     = ["0.0.0.0/0"]
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

variable "vault_output_prometheus" {
  description = "Create a Prometheus Client to serve the metrics for a Prometheus server to scrape"
  default     = false
}

variable "vault_output_prometheus_service_name" {
  description = "Name of the service to advertise in Consul"
  default     = "prometheus-client"
}

variable "vault_output_prometheus_service_port" {
  description = "Port of the Prometheus Client"
  default     = 9273
}

variable "vault_output_prometheus_service_cidrs" {
  description = "List of CIDRs that the Prometheus client will permit scraping. Remember to allow 127.0.0.1/32 for Consul health checks."
  default     = ["0.0.0.0/0"]
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
