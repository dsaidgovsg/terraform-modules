# AWS Elasticsearch module

This modules creates an Elasticsearch cluster in a domain, with (optional) redirection
service to allow easy access to Kibana web interface.

## Registered `consul` service name

The registered `consul` service name is `elasticsearch`, and the default port
used is `443`.

The actual VPC service and port are registered in `consul`. Any other services
that require Elasticsearch service should always use the actual VPC service
name, since the service is hosted under SSL and the SSL certificate to accept is
registered under the VPC name (and not the `consul` service name).

## Default Access Policy

Access control to AWS Elasticsearch domain is controlled by a
[combination](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-ac.html)
of its security group, resource based policy, and identity based policy.

This module sets up the following access controls:

- A security group to allow access to its HTTPS endpoint on port 443 to the list of CIDRs provided in the `es_access_cidr_block` variable. If you wish to add rules to the security group, you can add rules to the Security Group ID under the output `security_group_id`.
- The resource based policy attached to Elasticsearch allows HTTP access to all Elasticsearch APIs by everyone by default. You can configure the list of IAM principals with the `es_http_iam_roles` variable, but you would now have to [sign](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-ac.html#es-managedomains-signing-service-requests) requests to Elasticseearch. This is not supported by many of the plugins.
- No one is granted explicit `DENY` or `ACCEPT` permissions to the configuration APIs for Elasticsearch provided by AWS. Use identity based policies to control this.

## Slow Index Logs

You can enable logging of slow indexing with the `enable_slow_index_log` variable. After applying
the Terraform module, you will have to manually configure Elasticsearch to log slow indexing.

See the
[instructions](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-createupdatedomains.html#es-createdomain-configure-slow-logs-indices)
for how to do so.

## Redirection

The module can optionally setup an ELB listener rule to redirect users to the Kibana interface
using a much friendlier URL.

We recommend that you use the internal ELB that was created by the `Core` module. For example, the
list below will list the pairs of variables in this module that can use the output from the `Core`
module:

- `var.lb_cname`: `module.core.internal_lb_dns_name`
- `var.lb_zone_id`: `module.core.internal_lb_zone_id`
- `var.redirect_listener_arn`: `module.core.internal_lb_https_listener_arn`

## Service Linked Role

If, while applying, you get the error

```
* aws_elasticsearch_domain.es: Error reading IAM Role
AWSServiceRoleForAmazonElasticsearchService: NoSuchEntity: The role with name
AWSServiceRoleForAmazonElasticsearchService cannot be found.
```

you can set `create_service_linked_role` to true.

You can see the relevant
[issue](https://github.com/terraform-providers/terraform-provider-aws/issues/5218).

## Example Terraform configuration with Core integration

```hcl
module "core" {
  # ...
}

module "es" {
  source = "github.com/GovTechSG/terraform-modules//modules/elasticsearch"

  es_domain_name       = "my-cloud-es"
  es_base_domain       = "${data.terraform_remote_state.core.base_domain}"
  es_access_cidr_block = ["1.2.3.4"]

  es_master_type     = "r4.xlarge.elasticsearch"
  es_instance_type   = "r4.xlarge.elasticsearch"
  es_instance_count  = "3"
  es_ebs_volume_size = "100"  # in GB
  es_ebs_volume_type = "gp2"

  security_group_name            = "my-cloud-es-sg"
  security_group_vpc_id          = "vpc-1a2b3c4d"
  security_group_additional_tags = "${data.terraform_remote_state.core.tags}"

  es_vpc_subnet_ids = [
    "subnet-1a2b3c4d",
  ]

  enable_slow_index_log = true
  slow_index_log_name   = "my-cloud-es-slow-index"

  # Optional section for redirecting users to the unfriendly Kibana URL

  use_redirect             = true
  redirect_route53_zone_id = "xxx"
  redirect_domain          = "kibana.xxx.xxx"
  lb_cname                 = "${module.core.internal_lb_dns_name}"
  lb_zone_id               = "${module.core.internal_lb_zone_id}"
  redirect_listener_arn    = "${module.core.internal_lb_https_listener_arn}"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| KMS_key_error_alarm_name | Name of the alarm | string | `KMS_key_error_alarm` | no |
| KMS_key_error_enable | Whether to enable alarm | string | `true` | no |
| KMS_key_error_evaluation_periods | Number of periods to evaluate for the alarm. | string | `1` | no |
| KMS_key_error_period | Duration in seconds to evaluate for the alarm. | string | `60` | no |
| KMS_key_error_threshold | Threshold for the number of KMS key error | string | `1` | no |
| KMS_key_inaccessible_alarm_name | Name of the alarm | string | `KMS_key_inaccessible_alarm` | no |
| KMS_key_inaccessible_enable | Whether to enable alarm | string | `true` | no |
| KMS_key_inaccessible_evaluation_periods | Number of periods to evaluate for the alarm. | string | `1` | no |
| KMS_key_inaccessible_period | Duration in seconds to evaluate for the alarm. | string | `60` | no |
| KMS_key_inaccessible_threshold | Threshold for the number of KMS key inaccessible error | string | `1` | no |
| alarm_action | A list of ARNs (i.e. SNS Topic ARN) to notify for alarm action | string | `<list>` | no |
| cluster_index_writes_blocked_alarm_name | Name of the alarm | string | `cluster_index_writes_blocked_alarm` | no |
| cluster_index_writes_blocked_enable | Whether to enable alarm | string | `true` | no |
| cluster_index_writes_blocked_evaluation_periods | Number of periods to evaluate for the alarm. | string | `1` | no |
| cluster_index_writes_blocked_period | Duration in seconds to evaluate for the alarm. | string | `300` | no |
| cluster_index_writes_blocked_threshold | Threshold for the number of write request blocked | string | `1` | no |
| cluster_status_red_alarm_name | Name of the alarm. | string | `cluster_status_red_alarm` | no |
| cluster_status_red_enabled | Whether to enable alarm | string | `true` | no |
| cluster_status_red_evaluation_periods | Number of periods to evaluate for the alarm. | string | `1` | no |
| cluster_status_red_period | Duration in seconds to evaluate for the alarm. | string | `60` | no |
| cluster_status_red_threshold | Threshold for the number of primary shard not allocated to a node | string | `1` | no |
| cluster_status_yellow_alarm_name | Name of the alarm | string | `cluster_status_yellow_alarm` | no |
| cluster_status_yellow_enabled | Whether to enable alarm | string | `true` | no |
| cluster_status_yellow_evaluation_periods | Number of periods to evaluate for the alarm. | string | `1` | no |
| cluster_status_yellow_period | Duration in seconds to evaluate for the alarm. | string | `60` | no |
| cluster_status_yellow_threshold | Threshold for the number of replicas shard not allocated to a node | string | `1` | no |
| create_service_linked_role | Create Elasticsearch service linked role. See README | string | `false` | no |
| enable_slow_index_log | Enable slow log indexing | string | `false` | no |
| es_access_cidr_block | Elasticsearch access CIDR block to allow access | list | - | yes |
| es_additional_tags | Additional tags to apply on Elasticsearch | string | `<map>` | no |
| es_base_domain | Base domain for Elasticsearch cluster | string | - | yes |
| es_consul_service | Name to register in consul to identify Elasticsearch service | string | `elasticsearch` | no |
| es_default_access | Rest API / Web UI access | map | `<map>` | no |
| es_domain_name | Elasticsearch domain name | string | - | yes |
| es_ebs_volume_size | Volume capacity for attached EBS in GB for each node | string | - | yes |
| es_ebs_volume_type | Storage type of EBS volumes, if used (default gp2) | string | - | yes |
| es_encrypt_at_rest | Encrypts the data stored by Elasticsearch at rest | string | `false` | no |
| es_http_iam_roles | List of IAM role ARNs from which to permit Elasticsearch HTTP traffic (default ['*']). Note that a client must match both the IP address and the IAM role patterns in order to be permitted access. | list | `<list>` | no |
| es_instance_count | Number of nodes to be deployed in Elasticsearch | string | - | yes |
| es_instance_type | Elasticsearch instance type for non-master node | string | - | yes |
| es_kms_key_id | KMS Key ID for encryption at rest. Defaults to AWS service key. | string | `aws/es` | no |
| es_master_type | Elasticsearch instance type for dedicated master node | string | - | yes |
| es_snapshot_start_hour | Hour at which automated snapshots are taken, in UTC (default 0) | string | `19` | no |
| es_version | Elasticsearch version to deploy | string | `5.5` | no |
| es_vpc_subnet_ids | Subnet IDs for Elasticsearch cluster | list | - | yes |
| es_zone_awareness | Enable zone awareness for Elasticsearch cluster | string | `true` | no |
| high_cpu_utilization_data_node_alarm_name | Name of the alarm | string | `high_cpu_utilization_data_node_alarm` | no |
| high_cpu_utilization_data_node_enable | Whether to enable alarm | string | `true` | no |
| high_cpu_utilization_data_node_evaluation_periods | Number of periods to evaluate for the alarm. | string | `3` | no |
| high_cpu_utilization_data_node_period | Duration in seconds to evaluate for the alarm. | string | `900` | no |
| high_cpu_utilization_data_node_threshold | Threshold % of cpu utilization for data node | string | `80` | no |
| high_cpu_utilization_master_node_alarm_name | Name of the alarm | string | `high_cpu_utilization_master_node_alarm` | no |
| high_cpu_utilization_master_node_enable | Whether to enable alarm | string | `true` | no |
| high_cpu_utilization_master_node_evaluation_periods | Number of periods to evaluate for the alarm. | string | `3` | no |
| high_cpu_utilization_master_node_period | Duration in seconds to evaluate for the alarm. | string | `900` | no |
| high_cpu_utilization_master_node_threshold | Threshold % of cpu utilization for master node | string | `50` | no |
| high_jvm_memory_utilization_data_node_alarm_name | Name of the alarm | string | `high_jvm_memory_utilization_data_node_alarm` | no |
| high_jvm_memory_utilization_data_node_enable | Whether to enable alarm | string | `true` | no |
| high_jvm_memory_utilization_data_node_evaluation_periods | Number of periods to evaluate for the alarm. | string | `1` | no |
| high_jvm_memory_utilization_data_node_period | Duration in seconds to evaluate for the alarm. | string | `900` | no |
| high_jvm_memory_utilization_data_node_threshold | Threshold % of jvm memory utilization for data node | string | `80` | no |
| high_jvm_memory_utilization_master_node_alarm_name | Name of the alarm | string | `high_jvm_memory_utilization_master_node_alarm` | no |
| high_jvm_memory_utilization_master_node_enable | Whether to enable alarm | string | `true` | no |
| high_jvm_memory_utilization_master_node_evaluation_periods | Number of periods to evaluate for the alarm. | string | `1` | no |
| high_jvm_memory_utilization_master_node_period | Duration in seconds to evaluate for the alarm. | string | `900` | no |
| high_jvm_memory_utilization_master_node_threshold | Threshold % of jvm memory utilization for master node | string | `80` | no |
| lb_cname | DNS CNAME for the Load balancer | string | `` | no |
| lb_zone_id | Zone ID for the Load balancer DNS CNAME | string | `` | no |
| low_storage_space_enabled | Whether to enable alarm | string | `true` | no |
| low_storage_space_evaluation_periods | Number of periods to evaluate for the alarm. | string | `1` | no |
| low_storage_space_name | Name of the alarm | string | `low_storage_space_alarm` | no |
| low_storage_space_yellow_period | Duration in seconds to evaluate for the alarm. | string | `60` | no |
| node_unreachable_alarm_name | Name of the alarm | string | `node_unreachable_enable_alarm` | no |
| node_unreachable_enable | Whether to enable alarm | string | `true` | no |
| node_unreachable_evaluation_periods | Number of periods to evaluate for the alarm. | string | `1` | no |
| node_unreachable_period | Duration in seconds to evaluate for the alarm. | string | `86400` | no |
| ok_action | A list of ARNs (i.e. SNS Topic ARN) to notify for ok action | string | `<list>` | no |
| redirect_domain | Domain name to redirect | string | `` | no |
| redirect_listener_arn | LB listener ARN to attach the rule to | string | `` | no |
| redirect_route53_zone_id | Route53 Zone ID to create the Redirect Record in | string | `` | no |
| redirect_rule_priority | Rule priority for redirect | string | `100` | no |
| security_group_additional_tags | Additional tags to apply on the security group | string | `<map>` | no |
| security_group_name | Name of security group, leaving this empty generates a group name | string | - | yes |
| security_group_vpc_id | VPC ID to apply on the security group | string | - | yes |
| slow_index_additional_tags | Additional tags to apply on Cloudwatch log group | string | `<map>` | no |
| slow_index_log_name | Name of the Cloudwatch log group for slow index | string | `es-slow-index` | no |
| slow_index_log_retention | Number of days to retain logs for. | string | `120` | no |
| snapshot_failed_alarm_name | Name of the alarm | string | `snapshot_failed_alarm` | no |
| snapshot_failed_enable | Whether to enable alarm | string | `true` | no |
| snapshot_failed_evaluation_periods | Number of periods to evaluate for the alarm. | string | `1` | no |
| snapshot_failed_period | Duration in seconds to evaluate for the alarm. | string | `60` | no |
| snapshot_failed_threshold | Threshold for the number of snapshot failed | string | `1` | no |
| use_redirect | Indicates whether to use redirect users | string | `false` | no |


## Outputs

| Name | Description |
|------|-------------|
| arn | ARN of the created Elasticsearch domain |
| domain_id | Unique identifier for the domain |
| domain_name | Elasticsearch domain name |
| elasticsearch_url | Elasticsearch URL |
| endpoint | Domain-specific endpoint used to submit index, search, and data upload requests |
| kibana_url | Kibana URL |
| port | Elasticsearch service port |
| security_group_id | ID of the Security Group attached to Elasticsearch |
