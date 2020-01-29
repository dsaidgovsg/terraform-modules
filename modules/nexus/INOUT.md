## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| consul | n/a |
| template | n/a |
| vault | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| additional\_cidr\_blocks | Additional CIDR blocks other than the VPC CIDR block thatn can access the Nexus server | `list` | `[]` | no |
| allowed\_ssh\_cidr\_blocks | List of allowed CIDR blocks to allow SSH access | `list` | `[]` | no |
| ami\_id | AMI ID for Nexus Server | `string` | `""` | no |
| associate\_public\_ip\_address | Associate a public IP address for instance | `bool` | `false` | no |
| aws\_auth\_enabled | Enable AWS Authentication | `bool` | `false` | no |
| aws\_auth\_path | Path to the Vault AWS Authentication backend | `string` | `"aws"` | no |
| aws\_auth\_period\_minutes | Period, in minutes, that the Vault token issued will live for | `string` | `"60"` | no |
| aws\_auth\_policies | List of Vault policies to assign to the tokens issued by the AWS authentication backend | `list` | `[]` | no |
| aws\_auth\_vault\_role | Name of the role in the AWS Authentication backend to create | `string` | `"nexus"` | no |
| consul\_cluster\_tag\_key | Key that Consul Server Instances are tagged with for discovery | `string` | `"consul-servers"` | no |
| consul\_cluster\_tag\_value | Value that Consul Server Instances are tagged with for discovery | `string` | `"consul"` | no |
| consul\_key\_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has<br>        been applied. If you change this, you have to update the<br>        `integration_consul_prefix` variable in the core module as well. | `string` | `"terraform/"` | no |
| consul\_security\_group\_id | Security Group ID for Consul servers | `any` | n/a | yes |
| curator\_age | Age in days to retain indices | `string` | `"90"` | no |
| curator\_enable | Enable Curator integration for Nexus | `bool` | `false` | no |
| curator\_prefix | Elasticsearch prefix for Curator logs | `string` | `"services.nexus"` | no |
| data\_device\_name | Path of the EBS device that is mounted | `string` | `"/dev/nvme1n1"` | no |
| data\_volume\_id | EBS Volume ID for Nexus Data Storage | `any` | n/a | yes |
| data\_volume\_mount | Data volume mount device name | `string` | `"/dev/sdf"` | no |
| instance\_type | Type of instance to deploy | `string` | `"c5.large"` | no |
| name | Base name for resources | `string` | `"nexus"` | no |
| nexus\_ami\_prefix | AMI ID prefix for Nexus | `string` | `"nexus"` | no |
| nexus\_db\_dir | Path where the data for Nexus will be stored. This will be where the EBS volume where data is persisted will be mounted. | `string` | `"/opt/sonatype/sonatype-work"` | no |
| nexus\_port | Port at which the server will be listening to. | `string` | `"8081"` | no |
| nexus\_service | Name of Nexus server service to register in Consul. | `string` | `"nexus"` | no |
| root\_volume\_size | Size of the Nexus server root volume in GB | `number` | `50` | no |
| server\_type | Server type for the various types of modules integration | `string` | `"nexus"` | no |
| ssh\_key\_name | Name of SSH key to assign to the instance | `any` | n/a | yes |
| subdomain | Subdomain for Nexus server | `string` | `"nexus"` | no |
| subnet\_id | Subnet ID to deploy the instance to | `any` | n/a | yes |
| tags | Tags to apply to resources | `any` | n/a | yes |
| td\_agent\_enabled | Enable td-agent integration. You will still need to provide the appropriate configuration file for td-agent during the AMI building process. | `bool` | `false` | no |
| traefik\_enabled | Enable Traefik Integration | `bool` | `false` | no |
| traefik\_entrypoints | List of entrypoints for Traefik | `list` | <pre>[<br>  "internal"<br>]<br></pre> | no |
| traefik\_fqdns | List of FQDNs for Traefik to listen to. You have to create the DNS records separately. | `list` | `[]` | no |
| vault\_ssh\_enabled | Enable Vault SSH integration | `bool` | `false` | no |
| vault\_ssh\_max\_ttl | Max TTL for certificate renewal | `number` | `86400` | no |
| vault\_ssh\_path | Path to mount the SSH secrets engine | `string` | `"ssh_nexus"` | no |
| vault\_ssh\_role\_name | Role name for the Vault SSH secrets engine | `string` | `"default"` | no |
| vault\_ssh\_ttl | TTL for the Vault SSH certificate in seconds | `number` | `300` | no |
| vault\_ssh\_user | Username to allow SSH access | `string` | `"ubuntu"` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance\_id | Instance ID for the server |
| instance\_private\_ip | Private IP address for the server |
| security\_group\_id | Security Group ID for the instance |

