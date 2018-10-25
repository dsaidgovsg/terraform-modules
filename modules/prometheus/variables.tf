variable "prometheus_service" {
  description = "Name of Prometheus server service to register in Consul."
  default     = "prometheus"
}

variable "prometheus_client_service" {
  description = "Name of the Prometheus Client services to scrape"
  default     = "prometheus-client"
}

variable "prometheus_db_dir" {
  description = "Path where the data for Prometheus will be stored. This will be where the EBS volume where data is persisted will be mounted."
  default     = "/mnt/data"
}

variable "prometheus_port" {
  description = "Port at which the server will be listening to."
  default     = "9090"
}

variable "data_device_name" {
  description = "Path of the EBS device that is mounted"
  default     = "/dev/nvme1n1p1"
}

# --------------------------------------------------------------------------------------------------
# Traefik Integration
# --------------------------------------------------------------------------------------------------

variable "traefik_enabled" {
  description = "Enable Traefik Integration"
  default     = false
}

variable "traefik_entrypoints" {
  description = "List of entrypoints for Traefik"

  # Default "internal" entrypoint
  default = ["internal"]
}

variable "traefik_fqdns" {
  description = "List of FQDNs for Traefik to listen to. You have to create the DNS records separately."
  default     = []
}

# --------------------------------------------------------------------------------------------------
# CORE INTEGRATION SETTINGS
# --------------------------------------------------------------------------------------------------
variable "consul_key_prefix" {
  description = <<EOF
        Path prefix to the key in Consul to set for the `core` module to know that this module has
        been applied. If you change this, you have to update the
        `integration_consul_prefix` variable in the core module as well.
EOF

  default = "terraform/"
}
