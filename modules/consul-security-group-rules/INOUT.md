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
| cli\_rpc\_port | The port used by all agents to handle RPC from the CLI. | `number` | `8400` | no |
| dns\_port | The port used to resolve DNS queries. | `number` | `8600` | no |
| enable\_https\_port | If set to true, allow access to the Consul HTTPS port defined via the https\_api\_port variable. | `bool` | `false` | no |
| http\_api\_port | The port used by clients to talk to the HTTP API | `number` | `8500` | no |
| https\_api\_port | The port used by clients to talk to the HTTPS API. Only used if enable\_https\_port is set to true. | `number` | `8501` | no |
| security\_group\_id | The ID of the security group to which we should add the Consul security group rules | `string` | n/a | yes |
| serf\_lan\_port | The port used to handle gossip in the LAN. Required by all agents. | `number` | `8301` | no |
| serf\_wan\_port | The port used by servers to gossip over the WAN to other servers. | `number` | `8302` | no |
| server\_rpc\_port | The port used by servers to handle incoming requests from other agents. | `number` | `8300` | no |

## Outputs

No output.

