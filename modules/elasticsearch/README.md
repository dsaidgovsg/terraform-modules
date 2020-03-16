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
  es_access_cidr_block = ["1.3.1.4"]

  es_master_type     = "r5.xlarge.elasticsearch"
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

## Inputs and Outputs

Refer to [INOUT.md](INOUT.md)
