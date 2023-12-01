## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| allowed\_inbound\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Vault | `list(string)` | n/a | yes |
| allowed\_inbound\_security\_group\_count | The number of entries in var.allowed\_inbound\_security\_group\_ids. Ideally, this value could be computed dynamically, but we pass this variable to a Terraform resource's 'count' property and Terraform requires that 'count' be computed with literals or data sources only. | `any` | n/a | yes |
| allowed\_inbound\_security\_group\_ids | A list of security group IDs that will be allowed to connect to Vault | `list(string)` | n/a | yes |
| api\_port | The port to use for Vault API calls | `number` | `8200` | no |
| cluster\_port | The port to use for Vault server-to-server communication | `number` | `8201` | no |
| security\_group\_id | The ID of the security group to which we should add the Vault security group rules | `any` | n/a | yes |

## Outputs

No output.

