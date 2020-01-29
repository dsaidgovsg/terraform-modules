## Providers

| Name | Version |
|------|---------|
| consul | n/a |
| template | n/a |
| vault | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| consul\_key\_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has<br>        been applied. If you change this, you have to update the<br>        `integration_consul_prefix` variable in the core module as well. | `string` | `"terraform/"` | no |
| core\_integration | Enable integration with the `core` module by setting some values in Consul so<br>        that the user\_data scripts in core know that this module has been applied | `bool` | `true` | no |
| kv\_path | Path to the KV store | `string` | `"secret"` | no |
| kv\_subpath | Subpath inside the KV store to store the authentication | `string` | `"terraform/docker-auth"` | no |
| policy\_name | Name of the policy to allow for access to Docker registries | `string` | `"docker-auth"` | no |
| provision\_kv\_store | If you have not enabled a KV store for Vault, set this to `true` to provision one | `bool` | `false` | no |
| registries | A map of registries where the key is the URL of the registry and the value is of the form<br>`<username>:<password>` base64 encoded.<br><br>For example, on the shell, you can use the command `echo -n '<username>:<password>' \| base64 -w0`<br>to get the output required | `map` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| policy | Name of policy to allow access to the Docker Authentication secrets |

