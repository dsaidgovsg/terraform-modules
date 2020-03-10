## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| add\_private\_route53\_zone | Setting to true adds a new Route53 zone under the same domain name as `route53_zone`, but in a private zone, on top of the default public one | `bool` | `false` | no |
| allowed\_inbound\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Nomad | `list(string)` | n/a | yes |
| allowed\_ssh\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow SSH connections | `list(string)` | `[]` | no |
| ami\_id | The ID of the AMI to run in this cluster. Should be an AMI that had Nomad installed and configured by the install-nomad module. | `string` | n/a | yes |
| asg\_name | The name to use for the Auto Scaling Group | `string` | `""` | no |
| associate\_public\_ip\_address | If set to true, associate a public IP address with each EC2 Instance in the cluster. | `bool` | `false` | no |
| availability\_zones | The availability zones into which the EC2 Instances should be deployed. We recommend one availability zone per node in the cluster\_size variable. At least one of var.subnet\_ids or var.availability\_zones must be non-empty. | `list(string)` | `[]` | no |
| cluster\_name | The name of the cluster (e.g. nomad-servers-stage). This variable is used to namespace all resources created by this module. | `string` | `"fluentd-servers"` | no |
| cluster\_tag\_key | Add a tag with this key and the value var.cluster\_tag\_value to each Instance in the ASG. | `string` | `"nomad-servers"` | no |
| cluster\_tag\_value | Add a tag with key var.cluster\_tag\_key and this value to each Instance in the ASG. This can be used to automatically find other Consul nodes and form a cluster. | `string` | `"auto-join"` | no |
| desired\_capacity | The desired number of nodes to have in the cluster. If you're using this to run Nomad servers, we strongly recommend setting this to 3 or 5. | `number` | n/a | yes |
| ebs\_block\_devices | List of ebs volume definitions for those ebs\_volumes that should be added to the instances created with the EC2 launch-configuration. Each element in the list is a map containing keys defined for ebs\_block\_device (see: https://www.terraform.io/docs/providers/aws/r/launch_configuration.html#ebs_block_device. | `list` | `[]` | no |
| fluentd\_api\_domain | Domain to access Fluentd REST API | `any` | n/a | yes |
| fluentd\_port | Port on the Docker image in which the HTTP interface is exposed | `number` | `4224` | no |
| fluentd\_server\_lb\_deregistration\_delay | The time to wait for in-flight requests to complete while deregistering a target. During this time, the state of the target is draining. | `number` | `30` | no |
| health\_check\_grace\_period | Time, in seconds, after instance comes into service before checking health. | `number` | `300` | no |
| health\_check\_type | Controls how health checking is done. Must be one of EC2 or ELB. | `string` | `"EC2"` | no |
| http\_port | The port to use for HTTP | `number` | `4646` | no |
| instance\_profile\_path | Path in which to create the IAM instance profile. | `string` | `"/"` | no |
| instance\_type | The type of EC2 Instances to run for each node in the cluster (e.g. t2.micro). | `string` | n/a | yes |
| lb\_access\_log | Log Internal LB access to a S3 bucket | `bool` | `false` | no |
| lb\_access\_log\_bucket | S3 bucket to log access to the internal LB to | `any` | n/a | yes |
| lb\_access\_log\_prefix | Prefix in the S3 bucket to log internal LB access | `string` | `""` | no |
| lb\_health\_check\_interval | The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. | `number` | `30` | no |
| lb\_healthy\_threshold | The number of consecutive health checks successes required before considering an unhealthy target healthy (2-10). | `number` | `2` | no |
| lb\_idle\_timeout | The time in seconds that the connection is allowed to be idle. Consul supports blocking requests that can last up to 600 seconds. Increase this to support that. | `number` | `660` | no |
| lb\_incoming\_cidr | A list of CIDR-formatted IP address ranges from which the internal Load balancer is allowed to listen to | `list(string)` | n/a | yes |
| lb\_name | Name of the internal load balancer | `string` | `"fluentd-internal"` | no |
| lb\_subnets | List of subnets to deploy the internal LB to | `list(string)` | n/a | yes |
| lb\_tags | A map of tags to add to all resources | `map` | <pre>{<br>  "Environment": "development",<br>  "Terraform": "true"<br>}<br></pre> | no |
| lb\_unhealthy\_threshold | The number of consecutive health check failures required before considering a target unhealthy (2-10). | `number` | `2` | no |
| max\_size | The maximum number of nodes to have in the cluster. If you're using this to run Nomad servers, we strongly recommend setting this to 3 or 5. | `number` | n/a | yes |
| min\_size | The minimum number of nodes to have in the cluster. If you're using this to run Nomad servers, we strongly recommend setting this to 3 or 5. | `number` | n/a | yes |
| root\_volume\_delete\_on\_termination | Whether the volume should be destroyed on instance termination. | `bool` | `true` | no |
| root\_volume\_ebs\_optimized | If true, the launched EC2 instance will be EBS-optimized. | `bool` | `false` | no |
| root\_volume\_size | The size, in GB, of the root EBS volume. | `number` | `50` | no |
| root\_volume\_type | The type of volume. Must be one of: standard, gp2, or io1. | `string` | `"standard"` | no |
| route53\_zone | Zone for Route 53 records | `any` | n/a | yes |
| rpc\_port | The port to use for RPC | `number` | `4647` | no |
| security\_groups | Additional security groups to attach to the EC2 instances | `list(string)` | `[]` | no |
| serf\_port | The port to use for Serf | `number` | `4648` | no |
| ssh\_key\_name | The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair. | `string` | `""` | no |
| ssh\_port | The port used for SSH connections | `number` | `22` | no |
| subnet\_ids | The subnet IDs into which the EC2 Instances should be deployed. We recommend one subnet ID per node in the cluster\_size variable. At least one of var.subnet\_ids or var.availability\_zones must be non-empty. | `list(string)` | `[]` | no |
| tags | List of extra tag blocks added to the autoscaling group configuration. Each element in the list is a map containing keys 'key', 'value', and 'propagate\_at\_launch' mapped to the respective values. | <pre>list(object({<br>    key                 = string<br>    value               = string<br>    propagate_at_launch = bool<br>  }))<br></pre> | `[]` | no |
| tenancy | The tenancy of the instance. Must be one of: default or dedicated. | `string` | `"default"` | no |
| termination\_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | `string` | `"Default"` | no |
| tg\_group\_name | Name of the Fluentd server target group | `string` | `"fluentd-server-target-group"` | no |
| user\_data | A User Data script to execute while the server is booting. We remmend passing in a bash script that executes the run-nomad script, which should have been installed in the AMI by the install-nomad module. | `string` | `" "` | no |
| vpc\_id | The ID of the VPC in which to deploy the cluster | `string` | n/a | yes |
| wait\_for\_capacity\_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. | `string` | `"10m"` | no |

## Outputs

No output.

