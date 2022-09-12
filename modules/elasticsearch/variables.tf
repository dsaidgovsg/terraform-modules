#
# ES domain related
#

variable "security_group_name" {
  description = "Name of security group, leaving this empty generates a group name"
  type        = string
}

variable "security_group_vpc_id" {
  description = "VPC ID to apply on the security group"
  type        = string
}

variable "es_domain_name" {
  description = "Elasticsearch domain name"
  type        = string
}

variable "es_access_cidr_block" {
  description = "Elasticsearch access CIDR block to allow access"
  type        = list(string)
}

variable "es_vpc_subnet_ids" {
  description = "Subnet IDs for Elasticsearch cluster"
  type        = list(string)
}

variable "es_dedicated_master_enabled" {
  description = "Enable dedicated master nodes for Elasticsearch"
  type        = bool
}

variable "es_master_type" {
  # Available types: https://aws.amazon.com/elasticsearch-service/pricing/
  description = "Elasticsearch instance type for dedicated master node"
  type        = string
}

variable "es_master_count" {
  description = "Number of dedicated master nodes in Elasticsearch"
  type        = number
}

variable "es_instance_type" {
  description = "Elasticsearch instance type for non-master node"
  type        = string
}

variable "es_instance_count" {
  # Available types: https://aws.amazon.com/elasticsearch-service/pricing/
  description = "Number of nodes to be deployed in Elasticsearch"
  type        = number
}

variable "es_ebs_volume_size" {
  description = "Volume capacity for attached EBS in GB for each node"
  type        = number
}

variable "es_ebs_volume_type" {
  description = "Storage type of EBS volumes, if used (default gp2)"
  type        = string
}

variable "security_group_additional_tags" {
  description = "Additional tags to apply on the security group"
  type        = map(string)
  default     = {}
}

variable "es_default_access" {
  description = "Rest API / Web UI access"
  type        = map(any)

  default = {
    type     = "ingress"
    protocol = "tcp"
    port     = 443
  }
}

variable "es_version" {
  # Available versions: https://aws.amazon.com/elasticsearch-service/faqs/
  # Currently cannot use 6.X due to fluentd elasticsearch plugin output multiple type issue
  # Telegraf also does not support 6.X
  # See: https://github.com/uken/fluent-plugin-elasticsearch/issues/412
  description = "Elasticsearch version to deploy"

  default = "5.5"
}

variable "es_http_iam_roles" {
  description = <<EOF
List of IAM role ARNs from which to permit Elasticsearch HTTP traffic (default ['*']).
Note that a client must match both the IP address and the IAM role patterns in order to be permitted access.
EOF

  type    = list(string)
  default = ["*"]
}

variable "es_zone_awareness" {
  description = "Enable zone awareness for Elasticsearch cluster"
  default     = "true"
}

variable "es_availability_zone_count" {
  description = "Number of available zone count"
  default     = 3
}

variable "es_snapshot_start_hour" {
  description = "Hour at which automated snapshots are taken, in UTC (default 0)"
  default     = 19
}

variable "es_encrypt_at_rest" {
  description = "Encrypts the data stored by Elasticsearch at rest"
  default     = false
}

variable "es_kms_key_id" {
  description = "kms Key ID for encryption at rest. Defaults to AWS service key."
  default     = "aws/es"
}

variable "es_additional_tags" {
  description = "Additional tags to apply on Elasticsearch"
  type        = map(string)
  default     = {}
}

#
# ES Slow log settings
#

variable "enable_slow_index_log" {
  description = "Enable slow log indexing"
  default     = false
}

variable "slow_index_log_name" {
  description = "Name of the Cloudwatch log group for slow index"
  default     = "es-slow-index"
}

variable "slow_index_additional_tags" {
  description = "Additional tags to apply on Cloudwatch log group"
  type        = map(string)
  default     = {}
}

variable "slow_index_log_retention" {
  description = "Number of days to retain logs for."
  default     = "120"
}

#
# Alarm related
# for recommended cloudwatch alert: https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/cloudwatch-alarms.html

variable "alarm_actions" {
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify for alarm action"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "A list of ARNs (i.e. SNS Topic ARN) to notify for ok action"
  type        = list(string)
  default     = []
}

#
# Cluster_status_red
#

variable "cluster_status_red_enable" {
  description = "Whether to enable alarm"
  default     = false
}

variable "cluster_status_red_alarm_name" {
  description = "Name of the alarm."
  default     = "cluster_status_red_alarm"
}

variable "cluster_status_red_evaluation_periods" {
  description = "Number of periods to evaluate for the alarm."
  default     = "1"
}

variable "cluster_status_red_period" {
  description = "Duration in seconds to evaluate for the alarm."
  default     = "60"
}

variable "cluster_status_red_threshold" {
  description = "Threshold for the number of primary shard not allocated to a node"
  default     = "1"
}

#
# Cluster_status_yellow
#

variable "cluster_status_yellow_enable" {
  description = "Whether to enable alarm"
  default     = false
}

variable "cluster_status_yellow_alarm_name" {
  description = "Name of the alarm"
  default     = "cluster_status_yellow_alarm"
}

variable "cluster_status_yellow_evaluation_periods" {
  description = "Number of periods to evaluate for the alarm."
  default     = "1"
}

variable "cluster_status_yellow_period" {
  description = "Duration in seconds to evaluate for the alarm."
  default     = "60"
}

variable "cluster_status_yellow_threshold" {
  description = "Threshold for the number of replicas shard not allocated to a node"
  default     = "1"
}

#
# Low_storage_space
#

variable "low_storage_space_enable" {
  description = "Whether to enable alarm"
  default     = false
}

variable "low_storage_space_name" {
  description = "Name of the alarm"
  default     = "low_storage_space_alarm"
}

variable "low_storage_space_evaluation_periods" {
  description = "Number of periods to evaluate for the alarm."
  default     = "1"
}

variable "low_storage_space_yellow_period" {
  description = "Duration in seconds to evaluate for the alarm."
  default     = "60"
}

#
# Cluster_index_writes_blocked
#

variable "cluster_index_writes_blocked_enable" {
  description = "Whether to enable alarm"
  default     = false
}

variable "cluster_index_writes_blocked_alarm_name" {
  description = "Name of the alarm"
  default     = "cluster_index_writes_blocked_alarm"
}

variable "cluster_index_writes_blocked_evaluation_periods" {
  description = "Number of periods to evaluate for the alarm."
  default     = "1"
}

variable "cluster_index_writes_blocked_period" {
  description = "Duration in seconds to evaluate for the alarm."
  default     = "300"
}

variable "cluster_index_writes_blocked_threshold" {
  description = "Threshold for the number of write request blocked"
  default     = "1"
}

#
# Node_unreachable
#

variable "node_unreachable_enable" {
  description = "Whether to enable alarm"
  default     = false
}

variable "node_unreachable_alarm_name" {
  description = "Name of the alarm"
  default     = "node_unreachable_enable_alarm"
}

variable "node_unreachable_evaluation_periods" {
  description = "Number of periods to evaluate for the alarm."
  default     = "1"
}

variable "node_unreachable_period" {
  description = "Duration in seconds to evaluate for the alarm."
  default     = "86400"
}

#
# Snapshot_failed
#

variable "snapshot_failed_enable" {
  description = "Whether to enable alarm"
  default     = false
}

variable "snapshot_failed_alarm_name" {
  description = "Name of the alarm"
  default     = "snapshot_failed_alarm"
}

variable "snapshot_failed_evaluation_periods" {
  description = "Number of periods to evaluate for the alarm."
  default     = "1"
}

variable "snapshot_failed_period" {
  description = "Duration in seconds to evaluate for the alarm."
  default     = "60"
}

variable "snapshot_failed_threshold" {
  description = "Threshold for the number of snapshot failed"
  default     = "1"
}

#
# High_cpu_utilization_data_node
#

variable "high_cpu_utilization_data_node_enable" {
  description = "Whether to enable alarm"
  default     = false
}

variable "high_cpu_utilization_data_node_alarm_name" {
  description = "Name of the alarm"
  default     = "high_cpu_utilization_data_node_alarm"
}

variable "high_cpu_utilization_data_node_evaluation_periods" {
  description = "Number of periods to evaluate for the alarm."
  default     = "3"
}

variable "high_cpu_utilization_data_node_period" {
  description = "Duration in seconds to evaluate for the alarm."
  default     = "900"
}

variable "high_cpu_utilization_data_node_threshold" {
  description = "Threshold % of cpu utilization for data node"
  default     = "80"
}

#
# High_jvm_memory_utilization_data_node
#

variable "high_jvm_memory_utilization_data_node_enable" {
  description = "Whether to enable alarm"
  default     = false
}

variable "high_jvm_memory_utilization_data_node_alarm_name" {
  description = "Name of the alarm"
  default     = "high_jvm_memory_utilization_data_node_alarm"
}

variable "high_jvm_memory_utilization_data_node_evaluation_periods" {
  description = "Number of periods to evaluate for the alarm."
  default     = "1"
}

variable "high_jvm_memory_utilization_data_node_period" {
  description = "Duration in seconds to evaluate for the alarm."
  default     = "900"
}

variable "high_jvm_memory_utilization_data_node_threshold" {
  description = "Threshold % of jvm memory utilization for data node"
  default     = "80"
}

#
# High_cpu_utilization_master_node
#

variable "high_cpu_utilization_master_node_enable" {
  description = "Whether to enable alarm"
  default     = false
}

variable "high_cpu_utilization_master_node_alarm_name" {
  description = "Name of the alarm"
  default     = "high_cpu_utilization_master_node_alarm"
}

variable "high_cpu_utilization_master_node_evaluation_periods" {
  description = "Number of periods to evaluate for the alarm."
  default     = "3"
}

variable "high_cpu_utilization_master_node_period" {
  description = "Duration in seconds to evaluate for the alarm."
  default     = "900"
}

variable "high_cpu_utilization_master_node_threshold" {
  description = "Threshold % of cpu utilization for master node"
  default     = "50"
}

#
# High_jvm_memory_utilization_master_node
#

variable "high_jvm_memory_utilization_master_node_enable" {
  description = "Whether to enable alarm"
  default     = false
}

variable "high_jvm_memory_utilization_master_node_alarm_name" {
  description = "Name of the alarm"
  default     = "high_jvm_memory_utilization_master_node_alarm"
}

variable "high_jvm_memory_utilization_master_node_evaluation_periods" {
  description = "Number of periods to evaluate for the alarm."
  default     = "1"
}

variable "high_jvm_memory_utilization_master_node_period" {
  description = "Duration in seconds to evaluate for the alarm."
  default     = "900"
}

variable "high_jvm_memory_utilization_master_node_threshold" {
  description = "Threshold % of jvm memory utilization for master node"
  default     = "80"
}

#
# kms_key_error
#

variable "kms_key_error_enable" {
  description = "Whether to enable alarm"
  default     = false
}

variable "kms_key_error_alarm_name" {
  description = "Name of the alarm"
  default     = "kms_key_error_alarm"
}

variable "kms_key_error_evaluation_periods" {
  description = "Number of periods to evaluate for the alarm."
  default     = "1"
}

variable "kms_key_error_period" {
  description = "Duration in seconds to evaluate for the alarm."
  default     = "60"
}

variable "kms_key_error_threshold" {
  description = "Threshold for the number of kms key error"
  default     = "1"
}

#
# kms_key_inaccessible
#

variable "kms_key_inaccessible_enable" {
  description = "Whether to enable alarm"
  default     = false
}

variable "kms_key_inaccessible_alarm_name" {
  description = "Name of the alarm"
  default     = "kms_key_inaccessible_alarm"
}

variable "kms_key_inaccessible_evaluation_periods" {
  description = "Number of periods to evaluate for the alarm."
  default     = "1"
}

variable "kms_key_inaccessible_period" {
  description = "Duration in seconds to evaluate for the alarm."
  default     = "60"
}

variable "kms_key_inaccessible_threshold" {
  description = "Threshold for the number of kms key inaccessible error"
  default     = "1"
}

#
# Redirect-related
#
variable "use_redirect" {
  description = "Indicates whether to use redirect users "
  default     = false
}

variable "redirect_route53_zone_id" {
  description = "Route53 Zone ID to create the Redirect Record in"
  type        = string
}

variable "redirect_domain" {
  description = "Domain name to redirect"
  type        = string
}

variable "lb_cname" {
  description = "DNS CNAME for the Load balancer"
  type        = string
}

variable "lb_zone_id" {
  description = "Zone ID for the Load balancer DNS CNAME"
  type        = string
}

variable "redirect_listener_arn" {
  description = "LB listener ARN to attach the rule to"
  type        = string
}

variable "redirect_rule_priority" {
  description = "Rule priority for redirect"
  default     = 100
}

#
# Others
#
variable "create_service_linked_role" {
  description = "Create Elasticsearch service linked role. See README"
  default     = false
}

variable "es_consul_service" {
  description = "Name to register in consul to identify Elasticsearch service"
  default     = "elasticsearch"
}
