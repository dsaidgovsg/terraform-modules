#
# ES domain related
#

variable "security_group_vpc_id" {
  description = "VPC ID to apply on the security group"
}

variable "security_group_tags" {
  description = "Tags to apply on the security group"
  type        = "map"
}

variable "route53_zone_internal" {
  description = "AWS Route53 Zone Internal Domain for Elasticsearch cluster"
}

variable "es_access_cidr_block" {
  description = "Elasticsearch access CIDR block to allow access"
  type        = "list"
}

variable "es_vpc_subnet_ids" {
  description = "Subnet IDs for Elasticsearch cluster"
  type        = "list"
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

variable "security_group_name" {
  description = "Name of security group, leaving this empty generates a group name"
  default     = "l-cloud-es"
}

variable "es_consul_service" {
  description = "Name to register in consul to identify Elasticsearch service"
  default     = "elasticsearch"
}

variable "es_domain_name" {
  description = "Elasticsearch domain name"
  default     = "tf-l-cloud-es"
}

variable "es_version" {
  # Available versions: https://aws.amazon.com/elasticsearch-service/faqs/
  # Currently cannot use 6.X due to fluentd elasticsearch plugin output multiple type issue
  # See: https://github.com/uken/fluent-plugin-elasticsearch/issues/412
  description = "Elasticsearch version to deploy"

  default = "5.5"
}

variable "es_master_type" {
  # Available types: https://aws.amazon.com/elasticsearch-service/pricing/
  description = "Elasticsearch instance type for dedicated master node"
  default     = "r4.2xlarge.elasticsearch"
}

variable "es_instance_type" {
  description = "Elasticsearch instance type for non-master node"
  default     = "r4.2xlarge.elasticsearch"
}

variable "es_instance_count" {
  # Available types: https://aws.amazon.com/elasticsearch-service/pricing/
  description = "Number of nodes to be deployed in Elasticsearch"
  default     = "6"
}

variable "es_ebs_volume_size" {
  description = "Volume capacity for attached EBS in GB for each node"
  default     = "200"
}

variable "es_ebs_volume_type" {
  description = "Storage type of EBS volumes, if used (default gp2)"
  default     = "gp2"
}

variable "es_management_iam_roles" {
  description = <<EOF
List of IAM role ARNs from which to permit management traffic (default ['*']).
Note that a client must match both the IP address and the IAM role patterns in order to be permitted access.
EOF

  type        = "list"
  default     = ["*"]
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
  description = "KMS Key ID for encryption at rest. Not used if left empty."
  default     = ""
}

variable "es_additional_tags" {
  description = "Additional tags to apply on Elasticsearch"
  default     = {}
}

#
# Redirect related
#

variable "redirect_alias_name" {
  description = "Alias name of the internal redirect to kibana"
}

variable "redirect_job_region" {
  description = "AWS region to run the redirect job"
}

variable "redirect_job_vpc_azs" {
  description = "List of VPC AZs to run the redirect job in"
  type        = "list"
}

variable "redirect_job_name" {
  description = "Name of the job to redirect users to kibana"
  default     = "kibana-redirect"
}

variable "redirect_nginx_version" {
  description = "Image tag of Nginx to use"
  default     = "1.14-alpine"
}

variable "redirect_subdomain" {
  description = "Subdomain for internal redirect to kibana"
  default     = "kibana"
}
