## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| additional\_security\_group\_ids | A list of additional security group IDs to add to Consul EC2 Instances | `list(string)` | `[]` | no |
| allowed\_inbound\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Consul | `list(string)` | n/a | yes |
| allowed\_inbound\_security\_group\_count | The number of entries in var.allowed\_inbound\_security\_group\_ids. Ideally, this value could be computed dynamically, but we pass this variable to a Terraform resource's 'count' property and Terraform requires that 'count' be computed with literals or data sources only. | `number` | `0` | no |
| allowed\_inbound\_security\_group\_ids | A list of security group IDs that will be allowed to connect to Consul | `list(string)` | `[]` | no |
| allowed\_ssh\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow SSH connections | `list(string)` | `[]` | no |
| allowed\_ssh\_security\_group\_count | The number of entries in var.allowed\_ssh\_security\_group\_ids. Ideally, this value could be computed dynamically, but we pass this variable to a Terraform resource's 'count' property and Terraform requires that 'count' be computed with literals or data sources only. | `number` | `0` | no |
| allowed\_ssh\_security\_group\_ids | A list of security group IDs from which the EC2 Instances will allow SSH connections | `list(string)` | `[]` | no |
| ami\_id | The ID of the AMI to run in this cluster. Should be an AMI that had Consul installed and configured by the install-consul module. | `string` | n/a | yes |
| associate\_public\_ip\_address | If set to true, associate a public IP address with each EC2 Instance in the cluster. | `bool` | `false` | no |
| availability\_zones | The availability zones into which the EC2 Instances should be deployed. We recommend one availability zone per node in the cluster\_size variable. At least one of var.subnet\_ids or var.availability\_zones must be non-empty. | `list(string)` | n/a | yes |
| cli\_rpc\_port | The port used by all agents to handle RPC from the CLI. | `number` | `8400` | no |
| cluster\_name | The name of the Consul cluster (e.g. consul-stage). This variable is used to namespace all resources created by this module. | `string` | n/a | yes |
| cluster\_size | The number of nodes to have in the Consul cluster. We strongly recommended that you use either 3 or 5. | `number` | `3` | no |
| cluster\_tag\_key | Add a tag with this key and the value var.cluster\_tag\_value to each Instance in the ASG. This can be used to automatically find other Consul nodes and form a cluster. | `string` | `"consul-servers"` | no |
| cluster\_tag\_value | Add a tag with key var.clsuter\_tag\_key and this value to each Instance in the ASG. This can be used to automatically find other Consul nodes and form a cluster. | `string` | `"auto-join"` | no |
| dns\_port | The port used to resolve DNS queries. | `number` | `8600` | no |
| enable\_https\_port | If set to true, allow access to the Consul HTTPS port defined via the https\_api\_port variable. | `bool` | `false` | no |
| enable\_iam\_setup | If true, create the IAM Role, IAM Instance Profile, and IAM Policies. If false, these will not be created, and you can pass in your own IAM Instance Profile via var.iam\_instance\_profile\_name. | `bool` | `true` | no |
| enabled\_metrics | List of autoscaling group metrics to enable. | `list(string)` | `[]` | no |
| health\_check\_grace\_period | Time, in seconds, after instance comes into service before checking health. | `number` | `300` | no |
| health\_check\_type | Controls how health checking is done. Must be one of EC2 or ELB. | `string` | `"EC2"` | no |
| http\_api\_port | The port used by clients to talk to the HTTP API | `number` | `8500` | no |
| https\_api\_port | The port used by clients to talk to the HTTPS API. Only used if enable\_https\_port is set to true. | `number` | `8501` | no |
| iam\_instance\_profile\_name | If enable\_iam\_setup is false then this will be the name of the IAM instance profile to attach | `string` | n/a | yes |
| iam\_permissions\_boundary | If set, restricts the created IAM role to the given permissions boundary | `string` | n/a | yes |
| instance\_profile\_path | Path in which to create the IAM instance profile. | `string` | `"/"` | no |
| instance\_type | The type of EC2 Instances to run for each node in the cluster (e.g. t2.micro). | `string` | n/a | yes |
| protect\_from\_scale\_in | (Optional) Allows setting instance protection. The autoscaling group will not select instances with this setting for termination during scale in events. | `bool` | `false` | no |
| root\_volume\_delete\_on\_termination | Whether the volume should be destroyed on instance termination. | `bool` | `true` | no |
| root\_volume\_ebs\_optimized | If true, the launched EC2 instance will be EBS-optimized. | `bool` | `false` | no |
| root\_volume\_encrypted | Encrypt the root volume at rest | `bool` | `false` | no |
| root\_volume\_size | The size, in GB, of the root EBS volume. | `number` | `50` | no |
| root\_volume\_type | The type of volume. Must be one of: standard, gp2, or io1. | `string` | `"standard"` | no |
| security\_group\_tags | Tags to be applied to the LC security group | `map(string)` | `{}` | no |
| serf\_lan\_port | The port used to handle gossip in the LAN. Required by all agents. | `number` | `8301` | no |
| serf\_wan\_port | The port used by servers to gossip over the WAN to other servers. | `number` | `8302` | no |
| server\_rpc\_port | The port used by servers to handle incoming requests from other agents. | `number` | `8300` | no |
| service\_linked\_role\_arn | The ARN of the service-linked role that the ASG will use to call other AWS services | `string` | n/a | yes |
| spot\_price | The maximum hourly price to pay for EC2 Spot Instances. | `number` | n/a | yes |
| ssh\_key\_name | The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair. | `string` | n/a | yes |
| ssh\_port | The port used for SSH connections | `number` | `22` | no |
| subnet\_ids | The subnet IDs into which the EC2 Instances should be deployed. We recommend one subnet ID per node in the cluster\_size variable. At least one of var.subnet\_ids or var.availability\_zones must be non-empty. | `list(string)` | n/a | yes |
| tags | List of extra tag blocks added to the autoscaling group configuration. Each element in the list is a map containing keys 'key', 'value', and 'propagate\_at\_launch' mapped to the respective values. | `list(object({ key : string, value : string, propagate_at_launch : bool }))` | `[]` | no |
| tenancy | The tenancy of the instance. Must be one of: null, default or dedicated. For EC2 Spot Instances only null or dedicated can be used. | `string` | n/a | yes |
| termination\_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | `string` | `"Default"` | no |
| user\_data | A User Data script to execute while the server is booting. We recommend passing in a bash script that executes the run-consul script, which should have been installed in the Consul AMI by the install-consul module. | `string` | n/a | yes |
| vpc\_id | The ID of the VPC in which to deploy the Consul cluster | `string` | n/a | yes |
| wait\_for\_capacity\_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. | `string` | `"10m"` | no |

## Outputs

| Name | Description |
|------|-------------|
| asg\_name | This is the name for the autoscaling group generated by the module |
| cluster\_size | This is the desired size of the consul cluster in the autoscaling group |
| cluster\_tag\_key | This is the tag key used to allow the consul servers to autojoin |
| cluster\_tag\_value | This is the tag value used to allow the consul servers to autojoin |
| iam\_role\_arn | This is the arn of instance role if enable\_iam\_setup variable is set to true |
| iam\_role\_id | This is the id of instance role if enable\_iam\_setup variable is set to true |
| launch\_config\_name | This is the name of the launch\_configuration used to bootstrap the cluster instances |
| security\_group\_id | This is the id of security group that governs ingress and egress for the cluster instances |

