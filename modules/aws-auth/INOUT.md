## Providers

| Name | Version |
|------|---------|
| aws | >= 2.42, < 4.0.0 |
| consul | >= 2.5 |
| vault | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| aws\_auth\_path | Path to enable the AWS authentication method on | `string` | `"aws/"` | no |
| base\_policies | List of policies to assign to all tokens created via the AWS authentication method | `set(string)` | `[]` | no |
| consul\_iam\_role\_arn | ARN of the IAM role for Consul servers | `any` | n/a | yes |
| consul\_key\_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has<br>        been applied. If you change this, you have to update the<br>        `integration_consul_prefix` variable in the core module as well. | `string` | `"terraform/"` | no |
| consul\_policies | Policies to attach to Consul servers role | `set(string)` | `[]` | no |
| consul\_role | Name of the AWS authentication role for Consul servers | `string` | `"consul"` | no |
| core\_integration | Enable integration with the `core` module by setting some values in Consul so<br>        that the user\_data scripts in core know that this module has been applied | `bool` | `true` | no |
| iam\_policy\_name | Name of the IAM policy to allow Vault servers to authenticate with AWS | `string` | `"VaultAwsAuth"` | no |
| nomad\_client\_iam\_role\_arn | ARN of the IAM role for Nomad clients | `any` | n/a | yes |
| nomad\_client\_policies | Policies to attach to Nomad clients role | `set(string)` | `[]` | no |
| nomad\_client\_role | Name of the AWS authentication role for Nomad clients | `string` | `"nomad-client"` | no |
| nomad\_server\_iam\_role\_arn | ARN of the IAM role for Nomad servers | `any` | n/a | yes |
| nomad\_server\_policies | Policies to attach to Nomad servers role | `set(string)` | `[]` | no |
| nomad\_server\_role | Name of the AWS authentication role for Nomad servers | `string` | `"nomad-server"` | no |
| period\_minutes | The token should be renewed within the duration specified by this value.<br>At each renewal, the token's TTL will be set to the value of this field.<br>The maximum allowed lifetime of token issued using this role. Specified as a number of minutes. | `number` | `4320` | no |
| vault\_iam\_role\_arn | ARN of the IAM role for Vault servers | `any` | n/a | yes |
| vault\_iam\_role\_id | Vault IAM role ID to apply the policy to | `any` | n/a | yes |
| vault\_policies | Policies to attach to Vault servers role | `set(string)` | `[]` | no |
| vault\_role | Name of the AWS authentication role for Vault servers | `string` | `"vault"` | no |

## Outputs

| Name | Description |
|------|-------------|
| path | Path to the AWS authentication mount |

