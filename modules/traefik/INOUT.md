## Providers

| Name | Version |
|------|---------|
| aws | >= 2.7 |
| consul | >= 2.5 |
| nomad | >= 1.4 |
| template | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| access\_log\_enable | Enable access logging | `bool` | `true` | no |
| access\_log\_json | Log access in JSON | `bool` | `false` | no |
| additional\_docker\_config | Additional HCL to be added to the configuration for the Docker driver. Refer to the template Jobspec for what is already defined | `string` | `""` | no |
| deregistration\_delay | Time before an unhealthy Elastic Load Balancer target becomes removed | `number` | `60` | no |
| elb\_ssl\_policy | ELB SSL policy for HTTPs listeners. See https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html | `string` | `"ELBSecurityPolicy-TLS-1-2-2017-01"` | no |
| external\_certificate\_arn | ARN for the certificate to use for the external LB | `any` | n/a | yes |
| external\_lb\_incoming\_cidr | A list of CIDR-formatted IP address ranges from which the external Load balancer is allowed to listen to | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]<br></pre> | no |
| external\_lb\_name | Name of the external Nomad load balancer | `string` | `"traefik-external"` | no |
| external\_nomad\_clients\_asg | The Nomad Clients Autoscaling group to attach the external load balancer to | `any` | n/a | yes |
| healthy\_threshold | The number of consecutive health checks successes required before considering an unhealthy target healthy (2-10). | `number` | `2` | no |
| internal\_certificate\_arn | ARN for the certificate to use for the internal LB | `any` | n/a | yes |
| internal\_lb\_incoming\_cidr | A list of CIDR-formatted IP address ranges from which the internal load balancer is allowed to listen to | `list(string)` | `[]` | no |
| internal\_lb\_name | Name of the external Nomad load balancer | `string` | `"traefik-internal"` | no |
| internal\_nomad\_clients\_asg | The Nomad Clients Autoscaling group to attach the internal load balancer to | `any` | n/a | yes |
| interval | The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. | `number` | `30` | no |
| lb\_external\_access\_log | Log External Traefik LB access to a S3 bucket | `bool` | `false` | no |
| lb\_external\_access\_log\_bucket | S3 bucket to log access to the External Traefik LB to | `any` | n/a | yes |
| lb\_external\_access\_log\_prefix | Prefix in the S3 bucket to log External Traefik LB access | `string` | `""` | no |
| lb\_external\_subnets | List of subnets to deploy the external LB to | `list(string)` | n/a | yes |
| lb\_internal\_access\_log | Log internal Traefik LB access to a S3 bucket | `bool` | `false` | no |
| lb\_internal\_access\_log\_bucket | S3 bucket to log access to the internal Traefik LB to | `any` | n/a | yes |
| lb\_internal\_access\_log\_prefix | Prefix in the S3 bucket to log internal Traefik LB access | `string` | `""` | no |
| lb\_internal\_subnets | List of subnets to deploy the internal LB to | `list(string)` | n/a | yes |
| log\_json | Log in JSON format | `bool` | `false` | no |
| nomad\_clients\_external\_security\_group | The security group of the nomad clients that the external LB will be able to connect to | `any` | n/a | yes |
| nomad\_clients\_internal\_security\_group | The security group of the nomad clients that the internal LB will be able to connect to | `any` | n/a | yes |
| nomad\_clients\_node\_class | Job constraint Nomad Client Node Class name | `any` | n/a | yes |
| route53\_zone | Zone for Route 53 records | `any` | n/a | yes |
| tags | A map of tags to add to all resources | `map` | <pre>{<br>  "Environment": "development",<br>  "Terraform": "true"<br>}<br></pre> | no |
| timeout | The amount of time, in seconds, during which no response means a failed health check (2-60 seconds). | `number` | `5` | no |
| traefik\_consul\_catalog\_prefix | Prefix for Consul catalog tags for Traefik | `string` | `"traefik"` | no |
| traefik\_consul\_prefix | Prefix on Consul to store Traefik configuration to | `string` | `"traefik"` | no |
| traefik\_count | Number of copies of Traefik to run | `number` | `3` | no |
| traefik\_external\_base\_domain | Domain to expose the external Traefik load balancer | `any` | n/a | yes |
| traefik\_internal\_base\_domain | Domain to expose the external Traefik load balancer | `any` | n/a | yes |
| traefik\_priority | Priority of the Nomad job for Traefik. See https://www.nomadproject.io/docs/job-specification/job.html#priority | `number` | `50` | no |
| traefik\_ui\_domain | Domain to access Traefik UI | `any` | n/a | yes |
| traefik\_version | Docker image tag of the version of Traefik to run | `string` | `"v1.7.12-alpine"` | no |
| unhealthy\_threshold | The number of consecutive health check failures required before considering a target unhealthy (2-10). | `number` | `2` | no |
| vpc\_id | ID of the VPC to deploy the LB to | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| traefik\_external\_cname | URL that applications should set a CNAME record to for Traefik reverse proxy |
| traefik\_external\_lb\_dns | URL that applications should set a CNAME or ALIAS record to the external LB directly |
| traefik\_external\_zone | The canonical hosted zone ID of the external load balancer (to be used in a Route 53 Alias record). |
| traefik\_internal\_cname | URL that applications should set a CNAME record to for Traefik reverse proxy |
| traefik\_internal\_lb\_dns | URL that applications should set a CNAME or ALIAS record to the internal LB directly |
| traefik\_internal\_zone | The canonical hosted zone ID of the internal load balancer (to be used in a Route 53 Alias record). |
| traefik\_jobspec | Nomad Jobspec for the deployed Traefik reverse proxy |
| traefik\_lb\_external\_arn | ARN of the external load balancer |
| traefik\_lb\_external\_https\_listener\_arn | ARN of the HTTPS listener for the external load balancer |
| traefik\_lb\_external\_security\_group\_id | Security group ID for Traefik external LB |
| traefik\_lb\_internal\_arn | ARN of the internal load balancer |
| traefik\_lb\_internal\_https\_listener\_arn | ARN of the HTTPS listener for the internal load balancer |
| traefik\_lb\_internal\_security\_group\_id | Security group ID for Traefik internal LB |

