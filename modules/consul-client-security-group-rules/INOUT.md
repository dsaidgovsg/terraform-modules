## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| allowed\_inbound\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Consul | `list(string)` | `[]` | no |
| allowed\_inbound\_security\_group\_count | The number of entries in var.allowed\_inbound\_security\_group\_ids. Ideally, this value could be computed dynamically, but we pass this variable to a Terraform resource's 'count' property and Terraform requires that 'count' be computed with literals or data sources only. | `number` | `0` | no |
| allowed\_inbound\_security\_group\_ids | A list of security group IDs that will be allowed to connect to Consul | `list(string)` | `[]` | no |
| security\_group\_id | The ID of the security group to which we should add the Consul security group rules | `any` | n/a | yes |
| serf\_lan\_port | The port used to handle gossip in the LAN. Required by all agents. | `number` | `8301` | no |

## Outputs

No output.

