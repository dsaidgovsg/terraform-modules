## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| allowed\_inbound\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Nomad | `list(string)` | n/a | yes |
| allowed\_ssh\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow SSH connections | `list(string)` | `[]` | no |
| ami\_id | The ID of the AMI to run in this cluster. Should be an AMI that had Nomad installed and configured by the install-nomad module. | `string` | n/a | yes |
| asg\_name | The name to use for the Auto Scaling Group | `string` | `""` | no |
| associate\_public\_ip\_address | If set to true, associate a public IP address with each EC2 Instance in the cluster. | `bool` | `false` | no |
| availability\_zones | The availability zones into which the EC2 Instances should be deployed. We recommend one availability zone per node in the cluster\_size variable. At least one of var.subnet\_ids or var.availability\_zones must be non-empty. | `list(string)` | `[]` | no |
| cluster\_name | The name of the cluster (e.g. nomad-servers-stage). This variable is used to namespace all resources created by this module. | `string` | `"fluentd-server"` | no |
| cluster\_tag\_key | Add a tag with this key and the value var.cluster\_tag\_value to each Instance in the ASG. | `string` | `"fluentd-servers"` | no |
| cluster\_tag\_value | Add a tag with key var.cluster\_tag\_key and this value to each Instance in the ASG. This can be used to automatically find other Consul nodes and form a cluster. | `string` | `"auto-join"` | no |
| desired\_capacity | The desired number of nodes to have in the cluster. If you're using this to run Nomad servers, we strongly recommend setting this to 3 or 5. | `number` | n/a | yes |
| ebs\_block\_devices | List of ebs volume definitions for those ebs\_volumes that should be added to the instances created with the EC2 launch-configuration. Each element in the list is a map containing keys defined for ebs\_block\_device (see: https://www.terraform.io/docs/providers/aws/r/launch_configuration.html#ebs_block_device. | `list` | `[]` | no |
| health\_check\_grace\_period | Time, in seconds, after instance comes into service before checking health. | `number` | `300` | no |
| health\_check\_type | Controls how health checking is done. Must be one of EC2 or ELB. | `string` | `"EC2"` | no |
| http\_port | The port to use for HTTP | `number` | `4646` | no |
| instance\_profile\_path | Path in which to create the IAM instance profile. | `string` | `"/"` | no |
| instance\_type | The type of EC2 Instances to run for each node in the cluster (e.g. t2.micro). | `string` | n/a | yes |
| max\_size | The maximum number of nodes to have in the cluster. If you're using this to run Nomad servers, we strongly recommend setting this to 3 or 5. | `number` | n/a | yes |
| min\_size | The minimum number of nodes to have in the cluster. If you're using this to run Nomad servers, we strongly recommend setting this to 3 or 5. | `number` | n/a | yes |
| root\_volume\_delete\_on\_termination | Whether the volume should be destroyed on instance termination. | `bool` | `true` | no |
| root\_volume\_ebs\_optimized | If true, the launched EC2 instance will be EBS-optimized. | `bool` | `false` | no |
| root\_volume\_size | The size, in GB, of the root EBS volume. | `number` | `50` | no |
| root\_volume\_type | The type of volume. Must be one of: standard, gp2, or io1. | `string` | `"standard"` | no |
| rpc\_port | The port to use for RPC | `number` | `4647` | no |
| security\_group\_id | The ID of the security group to which we should add the security group rules | `string` | n/a | yes |
| security\_groups | Additional security groups to attach to the EC2 instances | `list(string)` | `[]` | no |
| serf\_port | The port to use for Serf | `number` | `4648` | no |
| ssh\_key\_name | The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair. | `string` | `""` | no |
| ssh\_port | The port used for SSH connections | `number` | `22` | no |
| subnet\_ids | The subnet IDs into which the EC2 Instances should be deployed. We recommend one subnet ID per node in the cluster\_size variable. At least one of var.subnet\_ids or var.availability\_zones must be non-empty. | `list(string)` | `[]` | no |
| tags | List of extra tag blocks added to the autoscaling group configuration. Each element in the list is a map containing keys 'key', 'value', and 'propagate\_at\_launch' mapped to the respective values. | <pre>list(object({<br>    key                 = string<br>    value               = string<br>    propagate_at_launch = bool<br>  }))<br></pre> | `[]` | no |
| tenancy | The tenancy of the instance. Must be one of: default or dedicated. | `string` | `"default"` | no |
| termination\_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | `string` | `"Default"` | no |
| user\_data | A User Data script to execute while the server is booting. | `string` | n/a | yes |
| vpc\_id | The ID of the VPC in which to deploy the cluster | `string` | n/a | yes |
| wait\_for\_capacity\_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. | `string` | `"10m"` | no |

## Outputs

| Name | Description |
|------|-------------|
| iam\_role\_arn | n/a |
| iam\_role\_id | n/a |

