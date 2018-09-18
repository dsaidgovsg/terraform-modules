#
# ES domain related
#

variable "security_group_name" {
  description = "Name of security group, leaving this empty generates a group name"
}

variable "security_group_vpc_id" {
  description = "VPC ID to apply on the security group"
}

variable "es_domain_name" {
  description = "Elasticsearch domain name"
}

variable "es_base_domain" {
  description = "Base domain for Elasticsearch cluster"
}

variable "es_access_cidr_block" {
  description = "Elasticsearch access CIDR block to allow access"
  type        = "list"
}

variable "es_vpc_subnet_ids" {
  description = "Subnet IDs for Elasticsearch cluster"
  type        = "list"
}

variable "es_master_type" {
  # Available types: https://aws.amazon.com/elasticsearch-service/pricing/
  description = "Elasticsearch instance type for dedicated master node"
}

variable "es_instance_type" {
  description = "Elasticsearch instance type for non-master node"
}

variable "es_instance_count" {
  # Available types: https://aws.amazon.com/elasticsearch-service/pricing/
  description = "Number of nodes to be deployed in Elasticsearch"
}

variable "es_ebs_volume_size" {
  description = "Volume capacity for attached EBS in GB for each node"
}

variable "es_ebs_volume_type" {
  description = "Storage type of EBS volumes, if used (default gp2)"
}

variable "security_group_additional_tags" {
  description = "Additional tags to apply on the security group"
  default     = {}
}

variable "es_default_access" {
  description = "Rest API / Web UI access"
  type        = "map"

  default = {
    type     = "ingress"
    protocol = "tcp"
    port     = 443
  }
}

variable "es_consul_service" {
  description = "Name to register in consul to identify Elasticsearch service"
  default     = "elasticsearch"
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

  type    = "list"
  default = ["*"]
}

variable "es_zone_awareness" {
  description = "Enable zone awareness for Elasticsearch cluster"
  default     = "true"
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
  description = "KMS Key ID for encryption at rest. Defaults to AWS service key."
  default     = "aws/es"
}

variable "es_additional_tags" {
  description = "Additional tags to apply on Elasticsearch"
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
  default     = {}
}

variable "slow_index_log_retention" {
  description = "Number of days to retain logs for."
  default     = "120"
}

#
# Redirect related
#

variable "use_redirect" {
  description = "Indicates whether to use redirect users "
  default     = false
}

variable "redirect_route53_zone_id" {
  description = "Route53 Zone ID to create the Redirect Record in"
  default     = ""
}

variable "redirect_domain" {
  description = "Domain name to redirect"
  default     = ""
}

variable "lb_cname" {
  description = "DNS CNAME for the Load balancer"
  default     = ""
}

variable "lb_zone_id" {
  description = "Zone ID for the Load balancer DNS CNAME"
  default     = ""
}

variable "redirect_listener_arn" {
  description = "LB listener ARN to attach the rule to"
  default     = ""
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
