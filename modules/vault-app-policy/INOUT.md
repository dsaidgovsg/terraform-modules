## Providers

| Name | Version |
|------|---------|
| template | n/a |
| vault | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| app | App name to set policy | `any` | n/a | yes |
| kv\_path | Vault Key/value prefix path to the secrets | `any` | n/a | yes |
| prefix | Prefix to prepend to the policy name | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| app\_policy | Name of Application level policy |
| app\_rendered\_content | Vault policy content at Application level |
| dev\_policy | Name of Developer level policy |
| dev\_rendered\_content | Vault policy content at Developer level |

