## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| allowed\_inbound\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Nomad Clients for API usage | `list` | n/a | yes |
| allowed\_ssh\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow SSH connections | `list` | `[]` | no |
| ami\_id | AMI ID for Nomad clients | `any` | n/a | yes |
| associate\_public\_ip\_address | If set to true, associate a public IP address with each EC2 Instance in the cluster. | `bool` | `true` | no |
| client\_node\_class | Nomad Client Node Class name for cluster identification | `string` | `"nomad-client"` | no |
| clients\_desired | The desired number of Nomad client nodes to deploy. | `number` | `6` | no |
| clients\_max | The max number of Nomad client nodes to deploy. | `number` | `8` | no |
| clients\_min | The minimum number of Nomad client nodes to deploy. | `number` | `3` | no |
| cluster\_name | Name of the Nomad Clients cluster | `string` | `"nomad-client"` | no |
| cluster\_tag\_key | The tag the Consul EC2 Instances will look for to automatically discover each other and form a cluster. | `string` | `"consul-servers"` | no |
| consul\_cluster\_name | Name of the Consul cluster to deploy | `string` | `"consul-nomad-prototype"` | no |
| docker\_privileged | Flag to enable privileged mode for Docker agent on Nomad client | `bool` | `false` | no |
| instance\_type | Type of instances to deploy Nomad servers to | `string` | `"t2.medium"` | no |
| integration\_consul\_prefix | The Consul prefix used by the various integration scripts during initial instance boot. | `string` | `"terraform/"` | no |
| integration\_service\_type | The 'server type' for this Nomad cluster. This is used in several integration.<br>If empty, this defaults to the `cluster_name` variable | `string` | `""` | no |
| nomad\_clients\_services\_inbound\_cidr | A list of CIDR-formatted IP address ranges (in addition to the VPC range) from which the services hosted on Nomad clients on ports 20000 to 32000 will accept connections from. | `list` | `[]` | no |
| root\_volume\_size | The size, in GB, of the root EBS volume. | `number` | `50` | no |
| root\_volume\_type | The type of volume. Must be one of: standard, gp2, or io1. | `string` | `"gp2"` | no |
| ssh\_key\_name | The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair. | `string` | `""` | no |
| termination\_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | `string` | `"Default"` | no |
| user\_data | The user data for the Nomad clients EC2 instances. If set to empty, the default template will be used | `string` | `""` | no |
| vpc\_id | ID of the VPC to deploy to | `any` | n/a | yes |
| vpc\_subnet\_ids | List of Subnet IDs to deploy to | `list` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| asg\_name | Name of auto-scaling group for Nomad Clients |
| client\_node\_class | Nomad Client Node Class name applied |
| cluster\_size | Number of Nomad Clients in the cluster |
| default\_user\_data | Default launch configuration user data for Nomad Clients |
| iam\_role\_arn | IAM Role ARN for Nomad Clients |
| iam\_role\_id | IAM Role ID for Nomad Clients |
| launch\_config\_name | Name of launch config for Nomad Clients |
| security\_group\_id | Security group ID for Nomad Clients |
| ssh\_key\_name | Name of SSH Key for SSH login authentication to Nomad Clients cluster |
| user\_data | User data used for Nomad Clients |

