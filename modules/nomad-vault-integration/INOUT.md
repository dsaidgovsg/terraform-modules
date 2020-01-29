## Providers

| Name | Version |
|------|---------|
| consul | n/a |
| template | n/a |
| vault | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| allow\_unauthenticated | Specifies if users submitting jobs to the Nomad server should be required to provide<br>        their own Vault token, proving they have access to the policies listed in the job.<br>        This option should be disabled in an untrusted environment. | `string` | `"false"` | no |
| consul\_key\_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has<br>        been applied. If you change this, you have to update the<br>        `integration_consul_prefix` variable in the core module as well. | `string` | `"terraform/"` | no |
| core\_integration | Enable integration with the `core` module by setting some values in Consul so<br>        that the user\_data scripts in core know that this module has been applied | `bool` | `true` | no |
| nomad\_cluster\_disallowed\_policies | Additional policies that tokens created by Nomad servers are not allowed to have | `list` | `[]` | no |
| nomad\_cluster\_policy | Name of the policy for tokens passed to Nomad servers | `string` | `"nomad-cluster"` | no |
| nomad\_cluster\_role | Name for the Token role that is used by the Nomad server to create tokens | `string` | `"nomad-cluster"` | no |
| nomad\_cluster\_suffix | Suffix to create tokens with. See https://www.vaultproject.io/api/auth/token/index.html#path_suffix for more information | `string` | `"nomad-cluster"` | no |
| nomad\_server\_policy | Name of the policy to allow for the creation of the token to pass to Nomad servers | `string` | `"nomad-server"` | no |
| nomad\_server\_role | Name of the token role that is used to create Tokens to pass to Nomad | `string` | `"nomad-server"` | no |

## Outputs

| Name | Description |
|------|-------------|
| nomad\_cluster\_policy | Policy that allows Nomad servers to create child tokens for jobs |
| nomad\_cluster\_policy\_name | Name of policy that allows Nomad servers to create child tokens for jobs |
| nomad\_cluster\_token\_role | Token role configuration to allow Nomad servers to create child tokens |
| nomad\_server\_policy | Policy that allows the creation of a token to pass to the Nomad cluster servers |
| nomad\_server\_policy\_name | Name of policy that allows the creation of a token to pass to the Nomad cluster servers |
| nomad\_server\_token\_role | Token role configuration to create a token with the nomad\_cluster policy |

