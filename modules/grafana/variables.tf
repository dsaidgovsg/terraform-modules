variable "grafana_fqdns" {
  description = "List of FQDNs to for Grafana to listen to"
  type        = "list"
}

variable "grafana_domain" {
  description = "Domain for Github/Google Oauth redirection. If not set, will use the first from `grafana_fqdns`"
  default     = ""
}

variable "grafana_vault_policies" {
  description = "List of Vault Policies for Grafana to retrieve the relevant secrets"
  type        = "list"
}

variable "aws_region" {
  default = "ap-southeast-1"
}

variable "nomad_azs" {
  description = "AZs which Nomad is deployed to. If left empty, the list of AZs from this region will be used"
  default     = []
}

variable "grafana_count" {
  description = "Number of copies of Grafana to run"
  default     = 3
}

variable "grafana_image" {
  description = "Docker image for Grafana"
  default     = "grafana/grafana"
}

variable "grafana_tag" {
  description = "Tag for Grafana Docker image"
  default     = "5.3.4"
}

variable "grafana_force_pull" {
  description = "Force pull an image. Useful if the tag is mutable."
  default     = "true"
}

variable "grafana_bind_addr" {
  description = "IP address to bind the service to"
  default     = "0.0.0.0"
}

variable "grafana_port" {
  description = "Port on the Docker image in which the HTTP interface is exposed. This is INTERNAL to the container."
  default     = 3000
}

variable "grafana_job_name" {
  description = "Nomad job name for service Grafana"
  default     = "grafana"
}

variable "nomad_clients_node_class" {
  description = "Job constraint Nomad Client Node Class name"
}

variable "grafana_entrypoints" {
  description = "List of Traefik entrypoints for the Grafana job"
  default     = ["internal"]
}

variable "grafana_router_logging" {
  description = "Set to true for Grafana to log all HTTP requests (not just errors). These are logged as Info level events to grafana log."
  default     = "true"
}

#
# Database Related
#
variable "grafana_database_type" {
  description = "Type of database for Grafana. `mysql` or `postgres` is supported"
}

variable "grafana_database_host" {
  description = "Host name of the database"
}

variable "grafana_database_port" {
  description = "Port of the database"
}

variable "grafana_database_name" {
  description = "Name of database for Grafana"
  default     = "grafana"
}

variable "grafana_database_ssl_mode" {
  description = "For Postgres, use either disable, require or verify-full. For MySQL, use either true, false, or skip-verify."
}

variable "vault_database_path" {
  description = "Path in Vault to retrieve the database credentials"
}

variable "vault_database_username_path" {
  description = "Path for the Go template to read the database username"
  default     = ".Data.username"
}

variable "vault_database_password_path" {
  description = "Path for the Go template to read the database password"
  default     = ".Data.password"
}

#
# Admin Related
#

variable "vault_admin_path" {
  description = "Path in Vault to retrieve the admin credentials"
}

variable "vault_admin_username_path" {
  description = "Path for the Go template to read the admin username"
  default     = ".Data.username"
}

variable "vault_admin_password_path" {
  description = "Path for the Go template to read the admin password"
  default     = ".Data.password"
}

variable "grafana_additional_config" {
  description = "Additional configuration. You can place Go templates in this variable to read secrets from Vault. See http://docs.grafana.org/auth/overview/"
  default     = ""
}

#
# Session Related
#
variable "session_provider" {
  description = "Type of session store"
  default     = "memory"
}

variable "session_config" {
  description = "A Go template string to template out the session provider configuration. Depends on the type of provider"
  default     = ""
}

#
# Data sources
#

variable "cloudwatch_datasource_aws_path" {
  description = "Path in Vault AWS Secrets engine to retrieve AWS credentials. Set to empty to disable."
  default     = ""
}

variable "cloudwatch_datasource_name" {
  description = "Name of the AWS Cloudwatch data source"
  default     = "Cloudwatch"
}

#
# Dashboards
#

variable "aws_billing_dashboard" {
  description = "If the Cloudwatch data source is enabled, set this to automatically import a billing dashboard"
  default     = true
}

variable "aws_cloudwatch_dashboard" {
  description = "If the Cloudwatch data source is enabled, set this to automatically import a Cloudwatch dashboard"
  default     = true
}

variable "additional_task_config" {
  description = "Additional HCL configuration for the task. See the README for more."
  default     = ""
}

variable "additional_driver_config" {
  description = "Additional HCL config for the Task docker driver."
  default     = ""
}
