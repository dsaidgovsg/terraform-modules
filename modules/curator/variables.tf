# --------------------------------------------------------------------------------------------------
# Job Settings
# --------------------------------------------------------------------------------------------------

variable "job_name" {
  description = "Name of the Nomad Job"
  default     = "curator"
}

variable "nomad_azs" {
  description = "AZs which Nomad is deployed to. If left empty, the list of AZs from this region will be used"
  type        = list(string)
  default     = []
}

variable "nomad_clients_node_class" {
  description = "Job constraint Nomad Client Node Class name"
}

variable "cron" {
  description = "Cron job schedule. See https://www.nomadproject.io/docs/job-specification/periodic.html#cron"
  default     = "@weekly"
}

variable "timezone" {
  description = "Timezone to run cron job scheduling"
  default     = "Asia/Singapore"
}

variable "docker_image" {
  description = "Docker Image to run the job"
}

variable "docker_tag" {
  description = "Docker tag to run"
  default     = "latest"
}

variable "force_pull" {
  description = "Force Nomad Clients to always force pull"
  default     = "false"
}

variable "entrypoint" {
  description = "Entrypoint for the Docker Image"
  default     = ["/curator/curator"]
}

variable "command" {
  description = "Command for the Docker Image"
  default     = ""
}

variable "args" {
  description = "Arguments for the Docker image"

  default = [
    "--config",
    "/config/config.yml",
    "/config/actions.yml",
  ]
}

variable "config_path" {
  description = "Path to render the configuration file in the Docker container"
  default     = "/config/config.yml"
}

variable "actions_path" {
  description = "Path to render the actions file in the Docker container"
  default     = "/config/actions.yml"
}

variable "elasticsearch_service" {
  description = "Name of the Elasticsearch service to lookup in Consul"
  default     = "elasticsearch"
}

variable "additional_docker_config" {
  description = "Additional HCL to be added to the configuration for the Docker driver. Refer to the template Jobspec for what is already defined"
  default     = ""
}

# --------------------------------------------------------------------------------------------------
# Curator Settings
# --------------------------------------------------------------------------------------------------

variable "consul_disable" {
  description = "Disable clearing Consul server log indices"
  default     = false
}

variable "consul_age" {
  description = "Age in days to clear Consul server log indices"
  default     = 90
}

variable "consul_prefix" {
  description = "Prefix for Consul server logs"
  default     = "services.consul."
}

variable "consul_template_disable" {
  description = "Disable clearing consul_template log indices"
  default     = false
}

variable "consul_template_age" {
  description = "Age in days to clear consul_template log indices"
  default     = 90
}

variable "consul_template_prefix" {
  description = "Prefix for consul_template logs"
  default     = "services.consul-template."
}

variable "nomad_disable" {
  description = "Disable clearing nomad log indices"
  default     = false
}

variable "nomad_age" {
  description = "Age in days to clear nomad log indices"
  default     = 90
}

variable "nomad_prefix" {
  description = "Prefix for nomad logs"
  default     = "services.nomad."
}

variable "vault_disable" {
  description = "Disable clearing vault log indices"
  default     = false
}

variable "vault_age" {
  description = "Age in days to clear vault log indices"
  default     = 90
}

variable "vault_prefix" {
  description = "Prefix for vault logs"
  default     = "services.vault."
}

variable "docker_disable" {
  description = "Disable clearing docker log indices"
  default     = false
}

variable "docker_age" {
  description = "Age in days to clear docker log indices"
  default     = 90
}

variable "docker_prefix" {
  description = "Prefix for docker logs"
  default     = "docker."
}

variable "cron_disable" {
  description = "Disable clearing cron log indices"
  default     = false
}

variable "cron_age" {
  description = "Age in days to clear cron log indices"
  default     = 90
}

variable "cron_prefix" {
  description = "Prefix for cron logs"
  default     = "system.cron."
}

variable "td_agent_disable" {
  description = "Disable clearing td_agent log indices"
  default     = false
}

variable "td_agent_age" {
  description = "Age in days to clear td_agent log indices"
  default     = 90
}

variable "td_agent_prefix" {
  description = "Prefix for td_agent logs"
  default     = "system.td-agent."
}

variable "telegraf_disable" {
  description = "Disable clearing telegraf log indices"
  default     = false
}

variable "telegraf_age" {
  description = "Age in days to clear telegraf log indices"
  default     = 90
}

variable "telegraf_prefix" {
  description = "Prefix for telegraf logs"
  default     = "system.telegraf."
}

variable "sshd_disable" {
  description = "Disable clearing sshd log indices"
  default     = false
}

variable "sshd_age" {
  description = "Age in days to clear sshd log indices"
  default     = 90
}

variable "sshd_prefix" {
  description = "Prefix for sshd logs"
  default     = "system.sshd."
}

variable "sudo_disable" {
  description = "Disable clearing sudo log indices"
  default     = false
}

variable "sudo_age" {
  description = "Age in days to clear sudo log indices"
  default     = 90
}

variable "sudo_prefix" {
  description = "Prefix for sudo logs"
  default     = "system.sudo."
}

variable "user_data_disable" {
  description = "Disable clearing user_data log indices"
  default     = false
}

variable "user_data_age" {
  description = "Age in days to clear user_data log indices"
  default     = 90
}

variable "user_data_prefix" {
  description = "Prefix for user_data logs"
  default     = "system.user_data."
}

variable "waf_disable" {
  description = "Disable clearing waf log indices"
  default     = false
}

variable "waf_age" {
  description = "Age in days to clear waf log indices"
  default     = 90
}

variable "waf_prefix" {
  description = "Prefix for waf logs"
  default     = "services.waf"
}

variable "eks_disable" {
  description = "Disable clearing eks log indices"
  default     = false
}

variable "eks_age" {
  description = "Age in days to clear eks log indices"
  default     = 90
}

variable "eks_prefix" {
  description = "Prefix for eks logs"
  default     = "eks"
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
