## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| consul | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| es\_consul\_service | Name to register in consul to identify Elasticsearch service | `string` | `"elasticsearch"` | no |
| es\_default\_access | Rest API / Web UI access | `map(any)` | <pre>{<br>  "port": 443,<br>  "protocol": "tcp",<br>  "type": "ingress"<br>}<br></pre> | no |
| es\_endpoint | Domain-specific endpoint used to submit index, search, and data upload requests | `any` | n/a | yes |
| es\_post\_access\_cidr\_block | Elasticsearch access CIDR block to allow access | `list(string)` | n/a | yes |
| es\_security\_group\_id | ID of the Security Group attached to Elasticsearch | `any` | n/a | yes |
| lb\_cname | DNS CNAME for the Load balancer | `string` | `""` | no |
| lb\_zone\_id | Zone ID for the Load balancer DNS CNAME | `string` | `""` | no |
| redirect\_domain | Domain name to redirect | `string` | `""` | no |
| redirect\_listener\_arn | LB listener ARN to attach the rule to | `string` | `""` | no |
| redirect\_route53\_zone\_id | Route53 Zone ID to create the Redirect Record in | `string` | `""` | no |
| redirect\_rule\_priority | Rule priority for redirect | `number` | `100` | no |
| use\_redirect | Indicates whether to use redirect users | `bool` | `false` | no |

## Outputs

No output.

