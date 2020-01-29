## Providers

| Name | Version |
|------|---------|
| consul | >= 2.5 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| consul\_enable | Enable SSH Certificate signing on Consul servers. The Consul servers will also install the CA<br>    from Vault automatically. | `bool` | `true` | no |
| consul\_key\_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has<br>        been applied. If you change this, you have to update the<br>        `nomad_vault_integration_consul_prefix` variable in the core module as well. | `string` | `"terraform/"` | no |
| consul\_path | Path for Consul servers SSH access | `string` | `"ssh_consul"` | no |
| max\_ttl | Max TTL for certificate renewal | `number` | `86400` | no |
| nomad\_client\_enable | Enable SSH Certificate signing on Nomad clients. The Nomad clients will also install the CA<br>    from Vault automatically. | `bool` | `true` | no |
| nomad\_client\_path | Path for Nomad clients SSH access | `string` | `"ssh_nomad_client"` | no |
| nomad\_server\_enable | Enable SSH Certificate signing on Nomad servers. The Nomad servers will also install the CA<br>    from Vault automatically. | `bool` | `true` | no |
| nomad\_server\_path | Path for Nomad servers SSH access | `string` | `"ssh_nomad_server"` | no |
| role\_name | Name of role for each of the types of instances. | `string` | `"default"` | no |
| ssh\_user | SSH user to allow SSH access | `string` | `"ubuntu"` | no |
| ttl | TTL for the certificate in seconds | `number` | `300` | no |
| vault\_enable | Enable SSH Certificate signing on Vault servers. The Vault servers will also install the CA<br>    from Vault automatically. | `bool` | `true` | no |
| vault\_path | Path for Vault servers SSH access | `string` | `"ssh_vault"` | no |

## Outputs

No output.

