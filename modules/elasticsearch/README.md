# AWS Elasticsearch module

This modules creates an Elasticsearch cluster in a domain, with redirection
service to allow easy access to Kibana web interface (requires DNS CNAME alias
to be set up).

## Registered `consul` service name

The registered `consul` service name is `elasticsearch`, and the default port
used is `443`.

The actual VPC service and port are registered in `consul`. Any other services
that require Elasticsearch service should always use the actual VPC service
name, since the service is hosted under SSL and the SSL certificate to accept is
registered under the VPC name (and not the `consul` service name).

## Example Terraform configuration

```hcl
module "es" {
  source = "../../../vendor/terraform-modules/modules/elasticsearch"

  es_domain_name       = "${var.es_domain_name}"
  es_base_domain       = "${data.terraform_remote_state.core.base_domain}"
  es_access_cidr_block = ["${data.aws_vpc.this.cidr_block}", "${data.terraform_remote_state.vpc_peering.vpc_peer_cidr_block}"]

  security_group_name            = "${var.security_group_name}"
  security_group_vpc_id          = "${data.terraform_remote_state.core.vpc_id}"
  security_group_additional_tags = "${data.terraform_remote_state.core.tags}"

  es_vpc_subnet_ids = [
    "${data.terraform_remote_state.core.vpc_private_subnets[0]}",
    "${data.terraform_remote_state.core.vpc_private_subnets[2]}",
  ]

  slow_index_additional_tags = "${data.terraform_remote_state.core.tags}"
  slow_index_log_name        = "${var.slow_index_log_name}"

  redirect_alias_name  = "${data.terraform_remote_state.traefik.traefik_internal_cname}"
  redirect_job_region  = "${data.terraform_remote_state.core.vpc_region}"
  redirect_job_vpc_azs = "${data.terraform_remote_state.core.vpc_azs}"
}
```

## Inputs

| Name                           | Description                                                                                                                                                                                 |  Type  |          Default          | Required |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----: | :-----------------------: | :------: |
| es_access_cidr_block           | Elasticsearch access CIDR block to allow access                                                                                                                                             |  list  |             -             |   yes    |
| es_additional_tags             | Additional tags to apply on Elasticsearch                                                                                                                                                   | string |          `<map>`          |    no    |
| es_base_domain                 | Base domain for Elasticsearch cluster                                                                                                                                                       | string |             -             |   yes    |
| es_consul_service              | Name to register in consul to identify Elasticsearch service                                                                                                                                | string |      `elasticsearch`      |    no    |
| es_default_access              | Rest API / Web UI access                                                                                                                                                                    |  map   |          `<map>`          |    no    |
| es_domain_name                 | Elasticsearch domain name                                                                                                                                                                   | string |             -             |   yes    |
| es_ebs_volume_size             | Volume capacity for attached EBS in GB for each node                                                                                                                                        | string |           `200`           |    no    |
| es_ebs_volume_type             | Storage type of EBS volumes, if used (default gp2)                                                                                                                                          | string |           `gp2`           |    no    |
| es_encrypt_at_rest             | Encrypts the data stored by Elasticsearch at rest                                                                                                                                           | string |          `false`          |    no    |
| es_instance_count              | Number of nodes to be deployed in Elasticsearch                                                                                                                                             | string |            `6`            |    no    |
| es_instance_type               | Elasticsearch instance type for non-master node                                                                                                                                             | string | `r4.xlarge.elasticsearch` |    no    |
| es_kms_key_id                  | KMS Key ID for encryption at rest. Not used if left empty.                                                                                                                                  | string |          `` | no          |
| es_management_iam_roles        | List of IAM role ARNs from which to permit management traffic (default ['*']). Note that a client must match both the IP address and the IAM role patterns in order to be permitted access. |  list  |         `<list>`          |    no    |
| es_master_type                 | Elasticsearch instance type for dedicated master node                                                                                                                                       | string | `r4.xlarge.elasticsearch` |    no    |
| es_snapshot_start_hour         | Hour at which automated snapshots are taken, in UTC (default 0)                                                                                                                             | string |           `19`            |    no    |
| es_version                     | Elasticsearch version to deploy                                                                                                                                                             | string |           `5.5`           |    no    |
| es_vpc_subnet_ids              | Subnet IDs for Elasticsearch cluster                                                                                                                                                        |  list  |             -             |   yes    |
| es_zone_awareness              | Enable zone awareness for Elasticsearch cluster                                                                                                                                             | string |          `true`           |    no    |
| redirect_alias_name            | Alias name of the internal redirect to kibana                                                                                                                                               | string |             -             |   yes    |
| redirect_job_name              | Name of the job to redirect users to kibana                                                                                                                                                 | string |     `kibana-redirect`     |    no    |
| redirect_job_region            | AWS region to run the redirect job                                                                                                                                                          | string |             -             |   yes    |
| redirect_job_vpc_azs           | List of VPC AZs to run the redirect job in                                                                                                                                                  |  list  |             -             |   yes    |
| redirect_nginx_version         | Image tag of Nginx to use                                                                                                                                                                   | string |       `1.14-alpine`       |    no    |
| redirect_subdomain             | Subdomain for internal redirect to kibana                                                                                                                                                   | string |         `kibana`          |    no    |
| security_group_additional_tags | Additional tags to apply on the security group                                                                                                                                              | string |          `<map>`          |    no    |
| security_group_name            | Name of security group, leaving this empty generates a group name                                                                                                                           | string |             -             |   yes    |
| security_group_vpc_id          | VPC ID to apply on the security group                                                                                                                                                       | string |             -             |   yes    |
| slow_index_additional_tags     | Additional tags to apply on Cloudwatch log group                                                                                                                                            | string |          `<map>`          |    no    |
| slow_index_log_name            | Name of the Cloudwatch log group for slow index                                                                                                                                             | string |      `es-slow-index`      |    no    |
| slow_index_log_retention       | Number of days to retain logs for.                                                                                                                                                          | string |           `120`           |    no    |

## Outputs

| Name              | Description                                                                     |
| ----------------- | ------------------------------------------------------------------------------- |
| arn               | ARN of the created Elasticsearch domain                                         |
| domain_id         | Unique identifier for the domain                                                |
| elasticsearch_url | Elasticsearch URL                                                               |
| endpoint          | Domain-specific endpoint used to submit index, search, and data upload requests |
| kibana_url        | Kibana URL                                                                      |
| port              | Elasticsearch service port                                                      |
