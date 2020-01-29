## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| allowed\_cidr\_blocks | CIDR blocks to allow EFS port access into the security group | `list` | n/a | yes |
| efs\_ports | Ports to allow access to EFS | `map` | <pre>{<br>  "from": 2049,<br>  "protocol": "tcp",<br>  "to": 2049<br>}<br></pre> | no |
| enable\_encryption | Boolean to specify whether to enable KMS encryption for EFS | `bool` | `true` | no |
| kms\_additional\_tags | KMS key additional tags for EFS | `map` | `{}` | no |
| kms\_key\_alias | Alias for the KMS key for EFS. Must prefix with alias/.<br>Overrides kms\_key\_alias\_prefix if this is specified. | `string` | `""` | no |
| kms\_key\_alias\_prefix | Alias prefix for the KMS key for EFS. Current timestamp is used as the suffix.<br>Must prefix with alias/.<br>kms\_key\_alias is used instead if specified. | `string` | `"alias/efs-default-"` | no |
| kms\_key\_deletion\_window\_in\_days | Duration in days after which the key is deleted after destruction of the resource,<br>must be between 7 and 30 days | `number` | `30` | no |
| kms\_key\_description | Description to use for KMS key | `string` | `"Encryption key for EFS"` | no |
| kms\_key\_enable\_rotation | Specifies whether key rotation is enabled | `bool` | `true` | no |
| kms\_key\_policy\_json | JSON content of IAM policy to attach to the KMS key. Empty string to use root identifier as principal for all KMS actions. | `string` | `""` | no |
| security\_group\_description | Description of security group for EFS | `string` | `"Security group for EFS"` | no |
| security\_group\_name | Name of security group for EFS. Empty string to use a random name. | `string` | `""` | no |
| tags | Tags to apply to resources that allow it | `any` | n/a | yes |
| vpc\_id | ID of VPC to add the security group for the EFS setup | `any` | n/a | yes |
| vpc\_subnets | IDs of VPC subnets to add the mount targets in | `list` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| arn | ARN of EFS |
| dns\_name | DNS name of EFS |
| id | ID of EFS |
| kms\_key\_alias | KMS key alias used for EFS encryption |
| kms\_key\_arn | ARN of KMS key used for EFS encryption |
| kms\_key\_key\_id | Key ID of KMS key used for EFS encryption |
| mount\_target\_dns\_names | Mount target DNS names of EFS. The order of elements is the same as the order of the given vpc\_subnets. |
| mount\_target\_ids | Mount target IDs of EFS. The order of elements is the same as the order of the given vpc\_subnets. |
| root\_resource | ARN of EFS resource at root |
| security\_group\_arn | ARN of the EFS security group |
| security\_group\_id | ID of the EFS security group |
| security\_group\_name | Name of the EFS security group |

