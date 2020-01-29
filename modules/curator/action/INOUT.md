## Providers

| Name | Version |
|------|---------|
| consul | >= 2.5 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| age | Age in days for indices to be cleared | `number` | `90` | no |
| consul\_key\_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has<br>        been applied. If you change this, you have to update the<br>        `integration_consul_prefix` variable in the core module as well. | `string` | `"terraform/"` | no |
| disable | Disable this action | `bool` | `false` | no |
| key | Name fo the action | `any` | n/a | yes |
| prefix | Index prefix to filter | `string` | `""` | no |
| suffix | Index suffix to filter | `string` | `""` | no |

## Outputs

No output.

