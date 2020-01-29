## Providers

| Name | Version |
|------|---------|
| consul | >= 2.5 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| consul\_enabled | Enable td-agent for Consul servers | `bool` | `true` | no |
| consul\_key\_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has<br>        been applied. If you change this, you have to update the<br>        `integration_consul_prefix` variable in the core module as well. | `string` | `"terraform/"` | no |
| core\_integration | Enable integration with the `core` module by setting some values in Consul so<br>        that the user\_data scripts in core know that this module has been applied | `bool` | `true` | no |
| nomad\_client\_enabled | Enable td-agent for Nomad clients | `bool` | `true` | no |
| nomad\_server\_enabled | Enable td-agent for Nomad servers | `bool` | `true` | no |
| vault\_enabled | Enable td-agent for Vault servers | `bool` | `true` | no |

## Outputs

No output.

