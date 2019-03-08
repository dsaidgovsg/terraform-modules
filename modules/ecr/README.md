# AWS EC2 Container Registry Repository

Provides an EC2 Container Registry Repository.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| add\_route53\_record | Flag to state whether to add additional A record into Route53 | string | `"true"` | no |
| lb\_cname | DNS CNAME for the Load balancer. Only applicable if `add_route53_record` is `true` | string | `""` | no |
| lb\_zone\_id | Zone ID for the Load balancer DNS CNAME. Only applicable if `add_route53_record` is `true` | string | `""` | no |
| name | Name of AWS EC2 Container Registry repository | string | n/a | yes |
| redirect\_listener\_arn | LB listener ARN to attach the rule to. Only applicable if `add_route53_record` is `true` | string | `""` | no |
| redirect\_rule\_priority | Rule priority for redirect. Only applicable if `add_route53_record` is `true` | string | `"100"` | no |
| route53\_domain | Domain to set as A record for Route53. Only applicable if `add_route53_record` is `true` | string | `""` | no |
| route53\_zone\_id | Zone ID to use for Route53 record. Only applicable if `add_route53_record` is `true` | string | `""` | no |
| tags | A map of tags to add to all resources | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | Full ARN of AWS EC2 Container Registry repository |
| name | Name of AWS EC2 Container Registry repository |
| registry\_id | The registry ID where the repository was created |
| repository\_url | The URL of the repository, in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName |
| service\_url | The URL of the repository service, in the form aws_account_id.dkr.ecr.region.amazonaws.com |
| subdomain | Subdomain domain of the A record |
