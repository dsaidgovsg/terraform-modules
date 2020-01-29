## Providers

| Name | Version |
|------|---------|
| template | >= 2.0 |
| vault | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| description | The type of servers for this SSH engine mount point.<br>    Name will be used in the human friendly mount description. | `any` | n/a | yes |
| enabled | Enable deploying this SSH secrets mount | `bool` | `true` | no |
| max\_ttl | Max TTL for certificate renewal | `number` | `86400` | no |
| path | Mount Point of the Secrets Engine | `any` | n/a | yes |
| role\_name | Name of role to create for this mount point. | `string` | `"default"` | no |
| ssh\_user | SSH user to allow SSH access | `string` | `"ubuntu"` | no |
| ttl | TTL for the certificate in seconds | `number` | `300` | no |

## Outputs

No output.

