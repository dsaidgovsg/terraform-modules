## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| additional\_security\_group\_ids | A list of additional security group IDs to add to Vault EC2 Instances | `list(string)` | `[]` | no |
| allowed\_inbound\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Vault | `list(string)` | n/a | yes |
| allowed\_inbound\_security\_group\_count | The number of entries in var.allowed\_inbound\_security\_group\_ids. Ideally, this value could be computed dynamically, but we pass this variable to a Terraform resource's 'count' property and Terraform requires that 'count' be computed with literals or data sources only. | `any` | n/a | yes |
| allowed\_inbound\_security\_group\_ids | A list of security group IDs that will be allowed to connect to Vault | `list(string)` | n/a | yes |
| allowed\_ssh\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow SSH connections | `list(string)` | `[]` | no |
| allowed\_ssh\_security\_group\_ids | A list of security group IDs from which the EC2 Instances will allow SSH connections | `list(string)` | `[]` | no |
| ami\_id | The ID of the AMI to run in this cluster. Should be an AMI that had Vault installed and configured by the install-vault module. | `any` | n/a | yes |
| api\_port | The port to use for Vault API calls | `number` | `8200` | no |
| associate\_public\_ip\_address | If set to true, associate a public IP address with each EC2 Instance in the cluster. We strongly recommend against making Vault nodes publicly accessible, except through an ELB (see the vault-elb module). | `bool` | `false` | no |
| auto\_unseal\_kms\_key\_arn | (Vault Enterprise only) The arn of the KMS key used for unsealing the Vault cluster | `string` | `""` | no |
| availability\_zones | The availability zones into which the EC2 Instances should be deployed. You should typically pass in one availability zone per node in the cluster\_size variable. We strongly recommend against passing in only a list of availability zones, as that will run Vault in the default (and most likely public) subnets in your VPC. At least one of var.subnet\_ids or var.availability\_zones must be non-empty. | `list(string)` | n/a | yes |
| cluster\_extra\_tags | A list of additional tags to add to each Instance in the ASG. Each element in the list must be a map with the keys key, value, and propagate\_at\_launch | `list(object({ key : string, value : string, propagate_at_launch : bool }))` | `[]` | no |
| cluster\_name | The name of the Vault cluster (e.g. vault-stage). This variable is used to namespace all resources created by this module. | `any` | n/a | yes |
| cluster\_port | The port to use for Vault server-to-server communication. | `number` | `8201` | no |
| cluster\_size | The number of nodes to have in the cluster. We strongly recommend setting this to 3 or 5. | `any` | n/a | yes |
| cluster\_tag\_key | Add a tag with this key and the value var.cluster\_name to each Instance in the ASG. | `string` | `"Name"` | no |
| dynamo\_table\_name | Table name for the storage backend, required if `enable_dynamo_backend = true` | `string` | `""` | no |
| dynamo\_table\_region | Table region used for the instance policy. Uses the current region if not supplied. Global tables should use `*` to allow for a cross region deployment to write to their respective table | `string` | `""` | no |
| enable\_auto\_unseal | (Vault Enterprise only) Emable auto unseal of the Vault cluster | `bool` | `false` | no |
| enable\_dynamo\_backend | Whether to use a DynamoDB storage backend instead of Consul | `bool` | `false` | no |
| enable\_s3\_backend | Whether to configure an S3 storage backend in addition to Consul. | `bool` | `false` | no |
| enabled\_metrics | List of autoscaling group metrics to enable. | `list(string)` | `[]` | no |
| force\_destroy\_s3\_bucket | If 'configure\_s3\_backend' is enabled and you set this to true, when you run terraform destroy, this tells Terraform to delete all the objects in the S3 bucket used for backend storage. You should NOT set this to true in production or you risk losing all your data! This property is only here so automated tests of this module can clean up after themselves. Only used if 'enable\_s3\_backend' is set to true. | `bool` | `false` | no |
| health\_check\_grace\_period | Time, in seconds, after instance comes into service before checking health. | `number` | `300` | no |
| health\_check\_type | Controls how health checking is done. Must be one of EC2 or ELB. | `string` | `"EC2"` | no |
| iam\_permissions\_boundary | If set, restricts the created IAM role to the given permissions boundary | `string` | n/a | yes |
| instance\_profile\_path | Path in which to create the IAM instance profile. | `string` | `"/"` | no |
| instance\_type | The type of EC2 Instances to run for each node in the cluster (e.g. t2.micro). | `any` | n/a | yes |
| root\_volume\_delete\_on\_termination | Whether the volume should be destroyed on instance termination. | `bool` | `true` | no |
| root\_volume\_ebs\_optimized | If true, the launched EC2 instance will be EBS-optimized. | `bool` | `false` | no |
| root\_volume\_size | The size, in GB, of the root EBS volume. | `number` | `50` | no |
| root\_volume\_type | The type of volume. Must be one of: standard, gp2, or io1. | `string` | `"standard"` | no |
| s3\_bucket\_name | The name of the S3 bucket to create and use as a storage backend. Only used if 'enable\_s3\_backend' is set to true. | `string` | `""` | no |
| s3\_bucket\_tags | Tags to be applied to the S3 bucket. | `map(string)` | `{}` | no |
| security\_group\_tags | Tags to be applied to the LC security group | `map(string)` | `{}` | no |
| ssh\_key\_name | The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair. | `string` | `""` | no |
| ssh\_port | The port used for SSH connections. | `number` | `22` | no |
| subnet\_ids | The subnet IDs into which the EC2 Instances should be deployed. You should typically pass in one subnet ID per node in the cluster\_size variable. We strongly recommend that you run Vault in private subnets. At least one of var.subnet\_ids or var.availability\_zones must be non-empty. | `list(string)` | n/a | yes |
| tenancy | The tenancy of the instance. Must be one of: default or dedicated. | `string` | `"default"` | no |
| termination\_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | `string` | `"Default"` | no |
| user\_data | A User Data script to execute while the server is booting. We recommend passing in a bash script that executes the run-vault script, which should have been installed in the AMI by the install-vault module. | `any` | n/a | yes |
| vpc\_id | The ID of the VPC in which to deploy the cluster | `any` | n/a | yes |
| wait\_for\_capacity\_timeout | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. Setting this to '0' causes Terraform to skip all Capacity Waiting behavior. | `string` | `"10m"` | no |

## Outputs

| Name | Description |
|------|-------------|
| asg\_name | n/a |
| cluster\_size | n/a |
| cluster\_tag\_key | n/a |
| cluster\_tag\_value | n/a |
| iam\_instance\_profile\_arn | n/a |
| iam\_instance\_profile\_id | n/a |
| iam\_instance\_profile\_name | n/a |
| iam\_role\_arn | n/a |
| iam\_role\_id | n/a |
| iam\_role\_name | n/a |
| launch\_config\_name | n/a |
| s3\_bucket\_arn | n/a |
| security\_group\_id | n/a |

