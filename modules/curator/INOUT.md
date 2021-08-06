## Providers

| Name | Version |
|------|---------|
| aws | >= 2.42 |
| nomad | >= 1.4 |
| template | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| actions\_path | Path to render the actions file in the Docker container | `string` | `"/config/actions.yml"` | no |
| additional\_docker\_config | Additional HCL to be added to the configuration for the Docker driver. Refer to the template Jobspec for what is already defined | `string` | `""` | no |
| args | Arguments for the Docker image | `list` | <pre>[<br>  "--config",<br>  "/config/config.yml",<br>  "/config/actions.yml"<br>]<br></pre> | no |
| command | Command for the Docker Image | `string` | `""` | no |
| config\_path | Path to render the configuration file in the Docker container | `string` | `"/config/config.yml"` | no |
| consul\_age | Age in days to clear Consul server log indices | `number` | `90` | no |
| consul\_disable | Disable clearing Consul server log indices | `bool` | `false` | no |
| consul\_key\_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has<br>        been applied. If you change this, you have to update the<br>        `integration_consul_prefix` variable in the core module as well. | `string` | `"terraform/"` | no |
| consul\_prefix | Prefix for Consul server logs | `string` | `"services.consul."` | no |
| consul\_template\_age | Age in days to clear consul\_template log indices | `number` | `90` | no |
| consul\_template\_disable | Disable clearing consul\_template log indices | `bool` | `false` | no |
| consul\_template\_prefix | Prefix for consul\_template logs | `string` | `"services.consul-template."` | no |
| cron | Cron job schedule. See https://www.nomadproject.io/docs/job-specification/periodic.html#cron | `string` | `"@weekly"` | no |
| cron\_age | Age in days to clear cron log indices | `number` | `90` | no |
| cron\_disable | Disable clearing cron log indices | `bool` | `false` | no |
| cron\_prefix | Prefix for cron logs | `string` | `"system.cron."` | no |
| docker\_age | Age in days to clear docker log indices | `number` | `90` | no |
| docker\_disable | Disable clearing docker log indices | `bool` | `false` | no |
| docker\_image | Docker Image to run the job | `any` | n/a | yes |
| docker\_prefix | Prefix for docker logs | `string` | `"docker."` | no |
| docker\_tag | Docker tag to run | `string` | `"latest"` | no |
| elasticsearch\_service | Name of the Elasticsearch service to lookup in Consul | `string` | `"elasticsearch"` | no |
| entrypoint | Entrypoint for the Docker Image | `list` | <pre>[<br>  "/curator/curator"<br>]<br></pre> | no |
| force\_pull | Force Nomad Clients to always force pull | `string` | `"false"` | no |
| job\_name | Name of the Nomad Job | `string` | `"curator"` | no |
| nomad\_age | Age in days to clear nomad log indices | `number` | `90` | no |
| nomad\_azs | AZs which Nomad is deployed to. If left empty, the list of AZs from this region will be used | `list(string)` | `[]` | no |
| nomad\_clients\_node\_class | Job constraint Nomad Client Node Class name | `any` | n/a | yes |
| nomad\_disable | Disable clearing nomad log indices | `bool` | `false` | no |
| nomad\_prefix | Prefix for nomad logs | `string` | `"services.nomad."` | no |
| sshd\_age | Age in days to clear sshd log indices | `number` | `90` | no |
| sshd\_disable | Disable clearing sshd log indices | `bool` | `false` | no |
| sshd\_prefix | Prefix for sshd logs | `string` | `"system.sshd."` | no |
| sudo\_age | Age in days to clear sudo log indices | `number` | `90` | no |
| sudo\_disable | Disable clearing sudo log indices | `bool` | `false` | no |
| sudo\_prefix | Prefix for sudo logs | `string` | `"system.sudo."` | no |
| td\_agent\_age | Age in days to clear td\_agent log indices | `number` | `90` | no |
| td\_agent\_disable | Disable clearing td\_agent log indices | `bool` | `false` | no |
| td\_agent\_prefix | Prefix for td\_agent logs | `string` | `"system.td-agent."` | no |
| telegraf\_age | Age in days to clear telegraf log indices | `number` | `90` | no |
| telegraf\_disable | Disable clearing telegraf log indices | `bool` | `false` | no |
| telegraf\_prefix | Prefix for telegraf logs | `string` | `"system.telegraf."` | no |
| timezone | Timezone to run cron job scheduling | `string` | `"Asia/Singapore"` | no |
| user\_data\_age | Age in days to clear user\_data log indices | `number` | `90` | no |
| user\_data\_disable | Disable clearing user\_data log indices | `bool` | `false` | no |
| user\_data\_prefix | Prefix for user\_data logs | `string` | `"system.user_data."` | no |
| vault\_age | Age in days to clear vault log indices | `number` | `90` | no |
| vault\_disable | Disable clearing vault log indices | `bool` | `false` | no |
| vault\_prefix | Prefix for vault logs | `string` | `"services.vault."` | no |

## Outputs

No output.

