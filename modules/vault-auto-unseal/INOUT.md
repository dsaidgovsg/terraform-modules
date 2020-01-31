## Providers

| Name | Version |
|------|---------|
| aws | >= 2.7 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| enable\_kms\_vpce | Enable provisioning a VPC Endpoint for KMS | `bool` | `false` | no |
| kms\_key\_alias | Alias to apply to the KMS key. Must begin with `alias/` | `string` | `"alias/vault_auto_unseal"` | no |
| tags | Tags to apply to resources that support it | `map` | <pre>{<br>  "Terraform": "true"<br>}<br></pre> | no |
| vpc\_id | ID of the VPC to provision the endpoints in | `string` | `""` | no |
| vpce\_sg\_name | Name of the security group to provision for the KMS VPC Endpoint | `string` | `"KMS VPC Endpoint"` | no |
| vpce\_subnets | List of subnets to provision the VPC Endpoint in. The Autoscaling group for Vault must be configured to use the same subnets that the VPC Endpoint are provisioned in. Note that because the KMS VPCE might not be supported in all the Availability Zones, you should use the output from the module to provide the list of subnets for your Vault ASG. | `list(string)` | `[]` | no |
| vpce\_subnets\_count | Number of subnets provided in `vpce_subnets` | `number` | `0` | no |

## Outputs

| Name | Description |
|------|-------------|
| kms\_key\_arn | ARN of the KMS CMK provisioned |
| vpce\_kms\_dns\_name | DNS name for the KMS VPC Endpoint |
| vpce\_kms\_security\_group | ID of the security group created for the VPC endpoint |
| vpce\_kms\_subnets | List of subnets where the KMS VPC Endpoint was provisioned |

