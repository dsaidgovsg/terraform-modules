## Providers

| Name | Version |
|------|---------|
| aws | >= 2.42, < 4.0.0 |
| template | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| add\_private\_route53\_zone | Setting to true adds a new Route53 zone under the same domain name as `route53_zone`, but in a private zone, on top of the default public one | `bool` | `false` | no |
| allowed\_ssh\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow SSH connections | `list(string)` | `[]` | no |
| associate\_public\_ip\_address | If set to true, associate a public IP address with each EC2 Instance in the cluster. | `bool` | `true` | no |
| base\_domain | Base domain for all services | `string` | n/a | yes |
| client\_node\_class | Nomad Client Node Class name for cluster identification | `string` | `"nomad-client"` | no |
| cluster\_tag\_key | The tag the Consul EC2 Instances will look for to automatically discover each other and form a cluster. | `string` | `"consul-servers"` | no |
| consul\_allowed\_inbound\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Consul servers for API usage | `list(string)` | n/a | yes |
| consul\_ami\_id | AMI ID for Consul servers | `any` | n/a | yes |
| consul\_api\_domain | Domain to access Consul HTTP API | `any` | n/a | yes |
| consul\_cluster\_name | Name of the Consul cluster to deploy | `string` | `"consul"` | no |
| consul\_cluster\_size | The number of Consul server nodes to deploy. We strongly recommend using 3 or 5. | `number` | `3` | no |
| consul\_instance\_type | Type of instances to deploy Consul servers and clients to | `string` | `"t2.medium"` | no |
| consul\_lb\_deregistration\_delay | The time to wait for in-flight requests to complete while deregistering a target. During this time, the state of the target is draining. | `number` | `30` | no |
| consul\_lb\_healthy\_threshold | The number of consecutive health checks successes required before considering an unhealthy target healthy (2-10). | `number` | `2` | no |
| consul\_lb\_interval | The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. | `number` | `30` | no |
| consul\_lb\_timeout | The amount of time, in seconds, during which no response means a failed health check (2-60 seconds). | `number` | `5` | no |
| consul\_lb\_unhealthy\_threshold | The number of consecutive health check failures required before considering a target unhealthy (2-10). | `number` | `2` | no |
| consul\_root\_volume\_size | The size, in GB, of the root EBS volume. | `number` | `50` | no |
| consul\_root\_volume\_type | The type of volume. Must be one of: standard, gp2, or io1. | `string` | `"gp2"` | no |
| consul\_subnets | List of subnets to launch Connsul servers in | `list(string)` | n/a | yes |
| consul\_termination\_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | `string` | `"NewestInstance"` | no |
| consul\_user\_data | The user data for the Consul servers EC2 instances. If set to empty, the default template will be used | `string` | `""` | no |
| elb\_access\_log | Log Internal LB access to a S3 bucket | `bool` | `false` | no |
| elb\_access\_log\_bucket | S3 bucket to log access to the internal LB to | `any` | n/a | yes |
| elb\_access\_log\_prefix | Prefix in the S3 bucket to log internal LB access | `string` | `""` | no |
| elb\_idle\_timeout | The time in seconds that the connection is allowed to be idle. Consul supports blocking requests that can last up to 600 seconds. Increase this to support that. | `number` | `660` | no |
| elb\_ssl\_policy | ELB SSL policy for HTTPs listeners. See https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html | `string` | `"ELBSecurityPolicy-TLS-1-2-2017-01"` | no |
| iam\_permissions\_boundary | If set, restricts the created IAM role to the given permissions boundary | `string` | n/a | yes |
| integration\_consul\_prefix | The Consul prefix used by the various integration scripts during initial instance boot. | `string` | `"terraform/"` | no |
| internal\_lb\_certificate\_arn | ARN of the certificate to use for the internal LB | `any` | n/a | yes |
| internal\_lb\_drop\_invalid\_header\_fields | Set to true for internal load balancer to drop invalid header fields | `bool` | `true` | no |
| internal\_lb\_incoming\_cidr | A list of CIDR-formatted IP address ranges from which the internal Load balancer is allowed to listen to | `list(string)` | n/a | yes |
| internal\_lb\_name | Name of the internal load balancer | `string` | `"internal"` | no |
| internal\_lb\_subnets | List of subnets to deploy the internal LB to | `list(string)` | n/a | yes |
| nomad\_api\_domain | Domain to access Nomad REST API | `any` | n/a | yes |
| nomad\_client\_cluster\_name | Overrides `nomad_cluster_name` if specified. The name of the Nomad client cluster. | `string` | n/a | yes |
| nomad\_client\_instance\_type | Type of instances to deploy Nomad servers to | `string` | `"t2.medium"` | no |
| nomad\_client\_subnets | List of subnets to launch Nomad clients in | `list(string)` | n/a | yes |
| nomad\_client\_termination\_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | `string` | `"Default"` | no |
| nomad\_clients\_allowed\_inbound\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Nomad Clients servers for API usage | `list(string)` | n/a | yes |
| nomad\_clients\_ami\_id | AMI ID for Nomad clients | `any` | n/a | yes |
| nomad\_clients\_desired | The desired number of Nomad client nodes to deploy. | `number` | `6` | no |
| nomad\_clients\_docker\_privileged | Flag to enable privileged mode for Docker driver on Nomad client | `bool` | `false` | no |
| nomad\_clients\_docker\_volumes\_mounting | Flag to enable volume mounting for Docker driver on Nomad client | `bool` | `false` | no |
| nomad\_clients\_dynamic\_ports\_inbound\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the services hosted on Nomad clients on ports 20000 to 32000 will accept connections from. | `list(string)` | n/a | yes |
| nomad\_clients\_max | The max number of Nomad client nodes to deploy. | `number` | `8` | no |
| nomad\_clients\_min | The minimum number of Nomad client nodes to deploy. | `number` | `3` | no |
| nomad\_clients\_root\_volume\_size | The size, in GB, of the root EBS volume. | `number` | `50` | no |
| nomad\_clients\_root\_volume\_type | The type of volume. Must be one of: standard, gp2, or io1. | `string` | `"gp2"` | no |
| nomad\_clients\_user\_data | The user data for the Nomad clients EC2 instances. If set to empty, the default template will be used | `string` | `""` | no |
| nomad\_cluster\_name | The name of the Nomad cluster. Only used if `nomad_server_cluster_name` or `nomad_client_cluster_name` is unused. `-server` is appended for server cluster and `-client` is append for client cluster | `string` | `"nomad"` | no |
| nomad\_server\_cluster\_name | Overrides `nomad_cluster_name` if specified. The name of the Nomad server cluster. | `string` | n/a | yes |
| nomad\_server\_instance\_type | Type of instances to deploy Nomad servers to | `string` | `"t2.medium"` | no |
| nomad\_server\_lb\_deregistration\_delay | The time to wait for in-flight requests to complete while deregistering a target. During this time, the state of the target is draining. | `number` | `30` | no |
| nomad\_server\_lb\_healthy\_threshold | The number of consecutive health checks successes required before considering an unhealthy target healthy (2-10). | `number` | `2` | no |
| nomad\_server\_lb\_interval | The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. | `number` | `30` | no |
| nomad\_server\_lb\_timeout | The amount of time, in seconds, during which no response means a failed health check (2-60 seconds). | `number` | `5` | no |
| nomad\_server\_lb\_unhealthy\_threshold | The number of consecutive health check failures required before considering a target unhealthy (2-10). | `number` | `2` | no |
| nomad\_server\_subnets | List of subnets to launch Nomad servers in | `list(string)` | n/a | yes |
| nomad\_server\_termination\_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | `string` | `"NewestInstance"` | no |
| nomad\_servers\_allowed\_inbound\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Nomad Servers servers for API usage | `list(string)` | n/a | yes |
| nomad\_servers\_ami\_id | AMI ID for Nomad servers | `any` | n/a | yes |
| nomad\_servers\_num | The number of Nomad server nodes to deploy. We strongly recommend using 3 or 5. | `number` | `3` | no |
| nomad\_servers\_root\_volume\_size | The size, in GB, of the root EBS volume. | `number` | `50` | no |
| nomad\_servers\_root\_volume\_type | The type of volume. Must be one of: standard, gp2, or io1. | `string` | `"gp2"` | no |
| nomad\_servers\_user\_data | The user data for the Nomad servers EC2 instances. If set to empty, the default template will be used | `string` | `""` | no |
| route53\_zone | Zone for Route 53 records | `any` | n/a | yes |
| ssh\_key\_name | The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair. | `string` | `""` | no |
| tags | A map of tags to add to all resources | `map` | <pre>{<br>  "Environment": "development",<br>  "Terraform": "true"<br>}<br></pre> | no |
| vault\_allowed\_inbound\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Vault servers for API usage | `list(string)` | n/a | yes |
| vault\_allowed\_inbound\_security\_group\_count | The number of entries in var.allowed\_inbound\_security\_group\_ids.<br>  Ideally, this value could be computed dynamically,<br>  but we pass this variable to a Terraform resource's 'count' property and<br>  Terraform requires that 'count' be computed with literals or data sources only. | `number` | `0` | no |
| vault\_allowed\_inbound\_security\_group\_ids | A list of security group IDs that will be allowed to connect to Vault | `list(string)` | `[]` | no |
| vault\_ami\_id | AMI ID for Vault servers | `any` | n/a | yes |
| vault\_api\_domain | Domain to access Vault HTTP API | `any` | n/a | yes |
| vault\_auto\_unseal\_kms\_endpoint | A custom VPC endpoint for Vault to use for KMS as part of auto-unseal | `string` | `""` | no |
| vault\_auto\_unseal\_kms\_key\_arn | The ARN of the KMS key used for unsealing the Vault cluster | `string` | `""` | no |
| vault\_auto\_usneal\_kms\_key\_region | The AWS region where the encryption key lives. If unset, defaults to the current region | `string` | `""` | no |
| vault\_cluster\_name | The name of the Vault cluster (e.g. vault-stage). This variable is used to namespace all resources created by this module. | `string` | `"vault"` | no |
| vault\_cluster\_size | The number of nodes to have in the cluster. We strongly recommend setting this to 3 or 5. | `number` | `3` | no |
| vault\_enable\_auto\_unseal | Enable auto unseal of the Vault cluster | `bool` | `false` | no |
| vault\_enable\_s3\_backend | Whether to configure an S3 storage backend for Vault in addition to Consul. | `bool` | `false` | no |
| vault\_instance\_type | The type of EC2 Instances to run for each node in the cluster (e.g. t2.micro). | `string` | `"t2.medium"` | no |
| vault\_lb\_deregistration\_delay | The time to wait for in-flight requests to complete while deregistering a target. During this time, the state of the target is draining. | `number` | `30` | no |
| vault\_lb\_healthy\_threshold | The number of consecutive health checks successes required before considering an unhealthy target healthy (2-10). | `number` | `2` | no |
| vault\_lb\_interval | The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. | `number` | `30` | no |
| vault\_lb\_timeout | The amount of time, in seconds, during which no response means a failed health check (2-60 seconds). | `number` | `5` | no |
| vault\_lb\_unhealthy\_threshold | The number of consecutive health check failures required before considering a target unhealthy (2-10). | `number` | `2` | no |
| vault\_root\_volume\_size | The size, in GB, of the root EBS volume. | `number` | `50` | no |
| vault\_root\_volume\_type | The type of volume. Must be one of: standard, gp2, or io1. | `string` | `"gp2"` | no |
| vault\_s3\_bucket\_name | The name of the S3 bucket to create and use as a storage backend for Vault. Only used if 'vault\_enable\_s3\_backend' is set to true. | `string` | `""` | no |
| vault\_subnets | List of subnets to launch Vault servers in | `list(string)` | n/a | yes |
| vault\_termination\_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | `string` | `"NewestInstance"` | no |
| vault\_tls\_key\_policy\_arn | ARN of the IAM policy to allow the Vault EC2 instances to decrypt the encrypted TLS private key baked into the AMI. See README for more information. | `any` | n/a | yes |
| vault\_user\_data | The user data for the Vault servers EC2 instances. If set to empty, the default template will be used | `string` | `""` | no |
| vpc\_id | ID of the VPC to launch the module in | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| add\_private\_route53\_zone | Indicates if there is private zone used for the core setup |
| asg\_name\_consul\_servers | Name of Consul Server Autoscaling group |
| asg\_name\_nomad\_clients | Name of the Autoscaling group for Nomad Clients |
| asg\_name\_nomad\_servers | Name of Nomad Server Autoscaling group |
| consul\_api\_address | Address to access consul API |
| consul\_cluster\_tag\_key | Key that Consul Server Instances are tagged with for discovery |
| consul\_cluster\_tag\_value | Value that Consul Server Instances are tagged with for discovery |
| consul\_server\_default\_user\_data | Default launch configuration user data for Consul Server |
| consul\_server\_user\_data | Default launch configuration user data for Consul Server |
| iam\_role\_arn\_consul\_servers | IAM Role ARN for Consul servers |
| iam\_role\_arn\_nomad\_clients | IAM Role ARN for Nomad Clients |
| iam\_role\_arn\_nomad\_servers | IAM Role ARN for Nomad servers |
| iam\_role\_id\_consul\_servers | IAM Role ID for Consul servers |
| iam\_role\_id\_nomad\_clients | IAM Role ID for Nomad Clients |
| iam\_role\_id\_nomad\_servers | IAM Role ID for Nomad servers |
| internal\_lb\_dns\_name | DNS name of the internal LB |
| internal\_lb\_https\_listener\_arn | ARN of the HTTPS listener for the internal LB |
| internal\_lb\_id | ARN of the internal LB that exposes Nomad, Consul and Vault RPC |
| internal\_lb\_security\_group\_id | Security Group ID for the Internal LB |
| internal\_lb\_zone\_id | The canonical hosted zone ID of the internal load balancer |
| launch\_config\_name\_consul\_servers | Name of the Launch Configuration for Consul servers |
| launch\_config\_name\_nomad\_clients | Name of the Launch Configuration for Nomad Clients |
| launch\_config\_name\_nomad\_servers | Name of Launch Configuration for Nomad servers |
| node\_class\_nomad\_clients | Nomad Client Node Class name applied |
| nomad\_api\_address | Address to access nomad API |
| nomad\_client\_default\_user\_data | Default launch configuration user data for Nomad Client |
| nomad\_client\_user\_data | User data used by Nomad Client |
| nomad\_server\_default\_user\_data | Default launch configuration user data for Nomad Server |
| nomad\_server\_user\_data | User data used by Nomad Server |
| nomad\_servers\_cluster\_tag\_key | Key that Nomad Server Instances are tagged with for discovery |
| nomad\_servers\_cluster\_tag\_value | Value that Nomad servers are tagged with for discovery |
| num\_consul\_servers | Number of Consul servers in cluster |
| num\_nomad\_clients | The desired number of Nomad clients in cluster |
| num\_nomad\_servers | Number of Nomad servers in the cluster |
| private\_zone\_id | Private zone ID, only applicable when `add_private_route53_zone` is set to true |
| security\_group\_id\_consul\_servers | Security Group ID for Consul servers |
| security\_group\_id\_nomad\_clients | Security Group ID for Nomad Clients |
| security\_group\_id\_nomad\_servers | Security Group ID for Nomad servers |
| ssh\_key\_name | The name of the SSH key that all instances are launched with |
| vault\_api\_address | Address to access Vault API |
| vault\_asg\_name | Name of the Autoscaling group for Vault cluster |
| vault\_cluster\_default\_user\_data | Default launch configuration user data for Vault Cluster |
| vault\_cluster\_size | Number of instances in the Vault cluster |
| vault\_cluster\_user\_data | User data used by Vault Cluster |
| vault\_iam\_role\_arn | IAM Role ARN for Vault |
| vault\_iam\_role\_id | IAM Role ID for Vault |
| vault\_launch\_config\_name | Name of the Launch Configuration for Vault cluster |
| vault\_s3\_bucket\_arn | ARN of the S3 bucket that Vault's state is stored |
| vault\_security\_group\_id | ID of the Security Group for Vault |
| vault\_servers\_cluster\_tag\_key | Key that Vault instances are tagged with |
| vault\_servers\_cluster\_tag\_value | Value that Vault instances are tagged with |

