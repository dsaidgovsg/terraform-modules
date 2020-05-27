## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| add\_private\_route53\_zone | Setting to true adds a new Route53 zone under the same domain name as `route53_zone`, but in a private zone, on top of the default public one | `bool` | `false` | no |
| allowed\_inbound\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Nomad Clients for API usage | `list(string)` | n/a | yes |
| allowed\_ssh\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow SSH connections | `list(string)` | `[]` | no |
| ami\_id | AMI ID for Fluentd servers | `any` | n/a | yes |
| associate\_public\_ip\_address | If set to true, associate a public IP address with each EC2 Instance in the cluster. | `bool` | `true` | no |
| cluster\_name | Name of the Fluentd Server cluster | `string` | `"fluentd-server"` | no |
| desired\_size | The desired number of Fluentd server nodes to deploy. | `number` | `2` | no |
| elb\_ssl\_policy | ELB SSL policy for HTTPs listeners. See https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html | `string` | `"ELBSecurityPolicy-TLS-1-2-2017-01"` | no |
| fluentd\_api\_domain | Domain to access Fluentd REST API | `any` | n/a | yes |
| fluentd\_port | Port on the Docker image in which the HTTP interface is exposed | `number` | `4224` | no |
| fluentd\_server\_lb\_deregistration\_delay | The time to wait for in-flight requests to complete while deregistering a target. During this time, the state of the target is draining. | `number` | `30` | no |
| instance\_type | Type of instances to deploy Nomad servers to | `string` | `"t2.medium"` | no |
| lb\_access\_log | Log Internal LB access to a S3 bucket | `bool` | `false` | no |
| lb\_access\_log\_bucket | S3 bucket to log access to the internal LB to | `any` | n/a | yes |
| lb\_access\_log\_prefix | Prefix in the S3 bucket to log internal LB access | `string` | `""` | no |
| lb\_certificate\_arn | ARN of the certificate to use for the internal LB | `any` | n/a | yes |
| lb\_health\_check\_interval | The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. | `number` | `30` | no |
| lb\_healthy\_threshold | The number of consecutive health checks successes required before considering an unhealthy target healthy (2-10). | `number` | `2` | no |
| lb\_idle\_timeout | The time in seconds that the connection is allowed to be idle. Consul supports blocking requests that can last up to 600 seconds. Increase this to support that. | `number` | `660` | no |
| lb\_incoming\_cidr | A list of CIDR-formatted IP address ranges from which the internal Load balancer is allowed to listen to | `list(string)` | n/a | yes |
| lb\_name | Name of the internal load balancer | `string` | `"fluentd-internal"` | no |
| lb\_subnets | List of subnets to deploy the internal LB to | `list(string)` | n/a | yes |
| lb\_tags | A map of tags to add to all resources | `map` | <pre>{<br>  "Environment": "development",<br>  "Terraform": "true"<br>}<br></pre> | no |
| lb\_unhealthy\_threshold | The number of consecutive health check failures required before considering a target unhealthy (2-10). | `number` | `2` | no |
| max\_size | The max number of Fluentd server nodes to deploy. | `number` | `5` | no |
| min\_size | The minimum number of Fluentd server nodes to deploy. | `number` | `1` | no |
| root\_volume\_size | The size, in GB, of the root EBS volume. | `number` | `50` | no |
| root\_volume\_type | The type of volume. Must be one of: standard, gp2, or io1. | `string` | `"gp2"` | no |
| route53\_zone | Zone for Route 53 records | `any` | n/a | yes |
| s3\_logging\_arn | Policy ARN to write into S3 logs | `any` | n/a | yes |
| services\_inbound\_cidr | A list of CIDR-formatted IP address ranges (in addition to the VPC range) from which the Fluentd server on ports 20000 to 32000 will accept connections from. | `list(string)` | `[]` | no |
| ssh\_key\_name | The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair. | `string` | `""` | no |
| termination\_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | `string` | `"Default"` | no |
| tg\_group\_name | Name of the Fluentd server target group | `string` | `"fluentd-server"` | no |
| user\_data | The user data for the Fluentd server EC2 instances. If set to empty, the default template will be used | `string` | `""` | no |
| vpc\_id | ID of the VPC to deploy to | `any` | n/a | yes |
| vpc\_subnet\_ids | List of Subnet IDs to deploy to | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| security\_group\_id | Security Group ID for Fluentd servers |

