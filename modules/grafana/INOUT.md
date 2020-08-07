## Providers

| Name | Version |
|------|---------|
| aws | >= 2.42 |
| nomad | >= 1.4 |
| template | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| additional\_driver\_config | Additional HCL config for the Task docker driver. | `string` | `""` | no |
| additional\_task\_config | Additional HCL configuration for the task. See the README for more. | `string` | `""` | no |
| aws\_billing\_dashboard | If the Cloudwatch data source is enabled, set this to automatically import a billing dashboard | `bool` | `true` | no |
| aws\_cloudwatch\_dashboard | If the Cloudwatch data source is enabled, set this to automatically import a Cloudwatch dashboard | `bool` | `true` | no |
| aws\_region | n/a | `string` | `"ap-southeast-1"` | no |
| cloudwatch\_datasource\_aws\_path | Path in Vault AWS Secrets engine to retrieve AWS credentials. Set to empty to disable. | `string` | `""` | no |
| cloudwatch\_datasource\_name | Name of the AWS Cloudwatch data source | `string` | `"Cloudwatch"` | no |
| grafana\_additional\_config | Additional configuration. You can place Go templates in this variable to read secrets from Vault. See http://docs.grafana.org/auth/overview/ | `string` | `""` | no |
| grafana\_bind\_addr | IP address to bind the service to | `string` | `"0.0.0.0"` | no |
| grafana\_count | Number of copies of Grafana to run | `number` | `3` | no |
| grafana\_database\_host | Host name of the database | `any` | n/a | yes |
| grafana\_database\_name | Name of database for Grafana | `string` | `"grafana"` | no |
| grafana\_database\_port | Port of the database | `any` | n/a | yes |
| grafana\_database\_ssl\_mode | For Postgres, use either disable, require or verify-full. For MySQL, use either true, false, or skip-verify. | `any` | n/a | yes |
| grafana\_database\_type | Type of database for Grafana. `mysql` or `postgres` is supported | `any` | n/a | yes |
| grafana\_domain | Domain for Github/Google Oauth redirection. If not set, will use the first from `grafana_fqdns` | `string` | `""` | no |
| grafana\_entrypoints | List of Traefik entrypoints for the Grafana job | `list` | <pre>[<br>  "internal"<br>]<br></pre> | no |
| grafana\_force\_pull | Force pull an image. Useful if the tag is mutable. | `string` | `"true"` | no |
| grafana\_fqdns | List of FQDNs to for Grafana to listen to | `list(string)` | n/a | yes |
| grafana\_image | Docker image for Grafana | `string` | `"grafana/grafana"` | no |
| grafana\_job\_name | Nomad job name for service Grafana | `string` | `"grafana"` | no |
| grafana\_port | Port on the Docker image in which the HTTP interface is exposed. This is INTERNAL to the container. | `number` | `3000` | no |
| grafana\_router\_logging | Set to true for Grafana to log all HTTP requests (not just errors). These are logged as Info level events to grafana log. | `string` | `"true"` | no |
| grafana\_tag | Tag for Grafana Docker image | `string` | `"5.3.4"` | no |
| grafana\_vault\_policies | List of Vault Policies for Grafana to retrieve the relevant secrets | `list(string)` | n/a | yes |
| nomad\_azs | AZs which Nomad is deployed to. If left empty, the list of AZs from this region will be used | `list(string)` | `[]` | no |
| nomad\_clients\_node\_class | Job constraint Nomad Client Node Class name | `any` | n/a | yes |
| prometheus\_datasource\_name | Name of the Prometheus data source | `string` | `"Prometheus"` | no |
| prometheus\_service | If set, will query Consul for the Prometheus service and retrieve the host and port of a Prometheus server | `string` | `""` | no |
| session\_config | A Go template string to template out the session provider configuration. Depends on the type of provider | `string` | `""` | no |
| session\_provider | Type of session store | `string` | `"memory"` | no |
| vault\_admin\_password\_path | Path for the Go template to read the admin password | `string` | `".Data.password"` | no |
| vault\_admin\_path | Path in Vault to retrieve the admin credentials | `any` | n/a | yes |
| vault\_admin\_username\_path | Path for the Go template to read the admin username | `string` | `".Data.username"` | no |
| vault\_database\_password\_path | Path for the Go template to read the database password | `string` | `".Data.password"` | no |
| vault\_database\_path | Path in Vault to retrieve the database credentials | `any` | n/a | yes |
| vault\_database\_username\_path | Path for the Go template to read the database username | `string` | `".Data.username"` | no |

## Outputs

No output.

