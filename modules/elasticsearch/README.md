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

## Default Access Policy

Access control to AWS Elasticsearch domain is controlled by a
[combination](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-ac.html)
of its security group, resource based policy, and identity based policy.

This module sets up the following access controls:

- A security group to allow access to its HTTPS endpoint on port 443 to the list of CIDRs provided in the `es_access_cidr_block` variable. If you wish to add rules to the security group, you can add rules to the Security Group ID under the output `security_group_id`.
- The resource based policy attached to Elasticsearch allows HTTP access to all Elasticsearch APIs by everyone by default. You can configure the list of IAM principals with the `es_http_iam_roles` variable, but you would now have to [sign](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-ac.html#es-managedomains-signing-service-requests) requests to Elasticseearch. This is not supported by many of the plugins.
- No one is granted explicit `DENY` or `ACCEPT` permissions to the configuration APIs for Elasticsearch provided by AWS. Use identity based policies to control this.

## Example Terraform configuration with Core integration (and possibly Traefik)

```hcl
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

  slow_index_log_name = "my-cloud-es-slow-index"

  # Optional section, integration with Traefik
  # for redirecting users to the unfriendly Kibana URL

  use_redirect         = true
  redirect_job_name    = "kibana-redirect"
  redirect_alias_name  = "${data.terraform_remote_state.traefik.traefik_internal_cname}"
  redirect_job_region  = "ap-southeast-1"
  redirect_job_vpc_azs = [
    "ap-southeast-1a",
    "ap-southeast-1b",
    "ap-southeast-1c",
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
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
| nomad_clients_node_class | Job constraint Nomad Client Node Class name | string | - | yes |
| redirect_alias_name | Alias name of the internal redirect to Kibana | string | - | yes |
| redirect_job_name | Name of the job to redirect users to Kibana | string | - | yes |
| redirect_job_region | AWS region to run the redirect job | string | - | yes |
| redirect_job_vpc_azs | List of VPC AZs to run the redirect job in | list | - | yes |
| redirect_nginx_version | Image tag of Nginx to use | string | `1.14-alpine` | no |
| redirect_subdomain | Subdomain for internal redirect to Kibana | string | `kibana` | no |
| security_group_additional_tags | Additional tags to apply on the security group | string | `<map>` | no |
| security_group_name | Name of security group, leaving this empty generates a group name | string | - | yes |
| security_group_vpc_id | VPC ID to apply on the security group | string | - | yes |
| slow_index_additional_tags | Additional tags to apply on Cloudwatch log group | string | `<map>` | no |
| slow_index_log_name | Name of the Cloudwatch log group for slow index | string | `es-slow-index` | no |
| slow_index_log_retention | Number of days to retain logs for. | string | `120` | no |
| use_redirect | Indicates whether to use Redirect job for redirecting users to Kibana URL | string | `false` | no |

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
