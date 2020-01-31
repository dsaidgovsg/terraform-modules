## Providers

| Name | Version |
|------|---------|
| consul | >= 2.5 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| consul\_key\_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has<br>        been applied. If you change this, you have to update the<br>        `integration_consul_prefix` variable in the core module as well. | `string` | `"terraform/"` | no |
| core\_integration | Enable integration with the `core` module by setting some values in Consul so<br>        that the user\_data scripts in core know that this module has been applied | `bool` | `true` | no |
| enabled | Enable Telegraf for this server type | `bool` | `true` | no |
| output\_elasticsearch\_service\_name | Service name in Consul to lookup Elasticsearch URLs | `string` | `"elasticsearch"` | no |
| output\_elastisearch | Enable metrics output to Elasticsearch | `bool` | `false` | no |
| output\_prometheus | Create a Prometheus Client to serve the metrics for a Prometheus server to scrape | `bool` | `false` | no |
| output\_prometheus\_service\_cidrs | List of CIDRs that the Prometheus client will permit scraping. Remember to allow 127.0.0.1/32 for Consul health checks. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]<br></pre> | no |
| output\_prometheus\_service\_name | Name of the service to advertise in Consul | `string` | `"prometheus-client"` | no |
| output\_prometheus\_service\_port | Port of the Prometheus Client | `number` | `9273` | no |
| path | Path after `consul_key_prefix` to write keys to | `string` | `"telegraf/"` | no |
| server\_type | Server type | `any` | n/a | yes |

## Outputs

No output.

