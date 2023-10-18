variable "elasticsearch_hostname" {
  description = "Host name of Elasticsearch"
}

variable "elasticsearch_port" {
  description = "Port number of Elasticsearch"
}

#############################
# Optional Variables
#############################
variable "aws_region" {
  description = "Region of AWS for which this is deployed"
  default     = "ap-southeast-1"
}

variable "es6_support" {
  description = "Set to `true` if you are using Elasticsearch 6 and above to support the removal of mapping types (https://www.elastic.co/guide/en/elasticsearch/reference/current/removal-of-types.html)"
  default     = false
}

variable "nomad_azs" {
  description = "AZs which Nomad is deployed to. If left empty, the list of AZs from this region will be used"
  type        = list(string)
  default     = []
}

variable "node_class_operator" {
  description = "Nomad constrant operator (https://www.nomadproject.io/docs/job-specification/constraint.html#operator) to use for restricting Nomad clients node class. Use this with `node_class`. The default matches everything."
  default     = "regexp"
}

variable "node_class" {
  description = "Node class for Nomad clients to constraint the jobs to. Use this with `node_class_operator`. The default matches everything."
  default     = ".?"
}

variable "fluentd_image" {
  description = "Docker image for fluentd"
  default     = "govtechsg/fluentd-s3-elasticsearch"
}

variable "fluentd_tag" {
  description = "Tag for fluentd Docker image"
  default     = "1.2.5-latest"
}

variable "fluentd_port" {
  description = "Port on the Docker image in which the TCP interface is exposed"
  default     = 4224
}

variable "fluentd_conf_file" {
  description = "Rendered fluentd configuration file"
  default     = "alloc/config/fluent.conf"
}

variable "fluentd_force_pull" {
  description = "Force pull an image. Useful if the tag is mutable."
  default     = "false"
}

variable "fluentd_count" {
  description = "Number of copies of Fluentd to run"
  default     = 3
}

variable "additional_blocks" {
  description = "Additional blocks to be added to the Jobspec"
  default     = ""
}

variable "fluentd_cpu" {
  description = "CPU resource assigned to the fluentd job"
  default     = 3000
}

variable "fluentd_memory" {
  description = "Memory resource assigned to the fluentd job"
  default     = 512
}

#############################
# Vault related
#############################

variable "vault_address" {
  description = "Vault server address for custom execution of commands, required if `vault_sts_iam_permissions_boundary` is set"
  default     = ""
}

variable "vault_sts_path" {
  description = "If logging to S3 is enabled, provide to the path in Vault in which the AWS Secrets Engine is mounted"
  default     = ""
}

variable "vault_sts_iam_permissions_boundary" {
  description = "Optional IAM policy as permissions boundary for STS generated IAM user"
  type        = string
  default     = null
}

variable "log_vault_role" {
  description = "Name of the Vault role in the AWS secrets engine to provide credentials for fluentd to write to Elasticsearch and S3"
  default     = "fluentd_logger"
}

variable "log_vault_policy" {
  description = "Name of the Vault policy to allow creating AWS credentials to write to Elasticsearch and S3"
  default     = "fluentd_logger"
}

#############################
# S3 Logging related
#############################
variable "logs_s3_enabled" {
  description = "Enable to log to S3"
  default     = true
}

variable "logs_s3_bucket_name" {
  description = "Name of S3 bucket to store logs for long term archival"
  default     = ""
}

variable "logs_s3_abort_incomplete_days" {
  description = "Specifies the number of days after initiating a multipart upload when the multipart upload must be completed."
  default     = 7
}

variable "logs_s3_ia_transition_days" {
  description = "Number of days before logs are transitioned to IA. Must be > 30 days"
  default     = 90
}

variable "logs_s3_glacier_transition_days" {
  description = "Number of days before logs are transitioned to IA. Must be > var.logs_s3_ia_transition_days + 30 days"
  default     = 365
}

variable "logs_s3_policy" {
  description = "Name of the IAM policy to provision for write access to the bucket"
  default     = "LogsS3Write"
}

variable "logs_s3_storage_class" {
  description = "Default storage class to store logs in S3. Choose from `STANDARD`, `REDUCED_REDUNDANCY` or `STANDARD_IA`"
  default     = "STANDARD"
}

variable "inject_source_host" {
  description = "Inject the log source host name and address into the logs"
  default     = true
}

variable "weekly_index_enabled" {
  description = "Enable weekly indexing strategy for Fluentd Elasticsearch plugin. If disabled, default indexing strategy is daily."
  default     = true
}

variable "source_address_key" {
  description = "Key to inject the source address to"
  default     = "host"
}

variable "source_hostname_key" {
  description = "Key to inject the source hostname to"
  default     = "hostname"
}

variable "tags" {
  description = "Tags to apply to resources"

  default = {
    Terraform = "true"
  }
}

#############################
# CloudWatch Logging related
#############################
variable "logs_cloudwatch_enabled" {
  description = "Enable to log to CloudWatch"
  default     = false
}

variable "logs_log_group_name" {
  description = "Name of CloudWatch Log Group to store logs"
  default     = "/fluentd/logs"
}

variable "logs_retention_time" {
  description = "CloudWatch Log Retention Time"
  default     = 90
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

variable "enable_file_logging" {
  description = "Enable logging to file on the Nomad jobs. Useful for debugging, but not really needed for production"
  default     = "false"
}

variable "fluentd_match" {
  description = "Tags that fluentd should output to S3, CloudWatch and Elasticsearch"
  default     = "@ERROR app.** docker.** services.** system.** vault**"
}
