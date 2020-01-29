## Providers

| Name | Version |
|------|---------|
| consul | n/a |
| nomad | n/a |
| template | n/a |
| vault | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| consul\_key\_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has<br>        been applied. If you change this, you have to update the<br>        `integration_consul_prefix` variable in the core module as well. | `string` | `"terraform/"` | no |
| nomad\_address | FQDN of Nomad addresses to access. Include the port and protocol | `string` | `"http://nomad.service.consul:4646"` | no |
| path | Path to enable the Nomad secrets engine on Vault | `string` | `"nomad"` | no |

## Outputs

| Name | Description |
|------|-------------|
| path | Path to the Nomad secrets engine. Useful for implicit dependencies |

