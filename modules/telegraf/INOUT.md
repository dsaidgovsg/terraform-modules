## Providers

| Name | Version |
|------|---------|
| consul | >= 2.5 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| consul\_enabled | Enable Telegraf for Consul servers | `bool` | `true` | no |
| consul\_key\_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has<br>        been applied. If you change this, you have to update the<br>        `integration_consul_prefix` variable in the core module as well. | `string` | `"terraform/"` | no |
| consul\_output\_elasticsearch\_service\_name | Service name in Consul to lookup Elasticsearch URLs | `string` | `"elasticsearch"` | no |
| consul\_output\_elastisearch | Enable metrics output to Elasticsearch | `bool` | `false` | no |
| consul\_output\_prometheus | Create a Prometheus Client to serve the metrics for a Prometheus server to scrape | `bool` | `false` | no |
| consul\_output\_prometheus\_service\_cidrs | List of CIDRs that the Prometheus client will permit scraping. Remember to allow 127.0.0.1/32 for Consul health checks. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]<br></pre> | no |
| consul\_output\_prometheus\_service\_name | Name of the service to advertise in Consul | `string` | `"prometheus-client"` | no |
| consul\_output\_prometheus\_service\_port | Port of the Prometheus Client | `number` | `9273` | no |
| core\_integration | Enable integration with the `core` module by setting some values in Consul so<br>        that the user\_data scripts in core know that this module has been applied | `bool` | `true` | no |
| nomad\_client\_enabled | Enable Telegraf for Nomad clients | `bool` | `true` | no |
| nomad\_client\_output\_elasticsearch\_service\_name | Service name in Consul to lookup Elasticsearch URLs | `string` | `"elasticsearch"` | no |
| nomad\_client\_output\_elastisearch | Enable metrics output to Elasticsearch | `bool` | `false` | no |
| nomad\_client\_output\_prometheus | Create a Prometheus Client to serve the metrics for a Prometheus server to scrape | `bool` | `false` | no |
| nomad\_client\_output\_prometheus\_service\_cidrs | List of CIDRs that the Prometheus client will permit scraping. Remember to allow 127.0.0.1/32 for Consul health checks. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]<br></pre> | no |
| nomad\_client\_output\_prometheus\_service\_name | Name of the service to advertise in Consul | `string` | `"prometheus-client"` | no |
| nomad\_client\_output\_prometheus\_service\_port | Port of the Prometheus Client | `number` | `9273` | no |
| nomad\_server\_enabled | Enable Telegraf for Nomad servers | `bool` | `true` | no |
| nomad\_server\_output\_elasticsearch\_service\_name | Service name in Consul to lookup Elasticsearch URLs | `string` | `"elasticsearch"` | no |
| nomad\_server\_output\_elastisearch | Enable metrics output to Elasticsearch | `bool` | `false` | no |
| nomad\_server\_output\_prometheus | Create a Prometheus Client to serve the metrics for a Prometheus server to scrape | `bool` | `false` | no |
| nomad\_server\_output\_prometheus\_service\_cidrs | List of CIDRs that the Prometheus client will permit scraping. Remember to allow 127.0.0.1/32 for Consul health checks. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]<br></pre> | no |
| nomad\_server\_output\_prometheus\_service\_name | Name of the service to advertise in Consul | `string` | `"prometheus-client"` | no |
| nomad\_server\_output\_prometheus\_service\_port | Port of the Prometheus Client | `number` | `9273` | no |
| vault\_enabled | Enable Telegraf for Vault servers | `bool` | `true` | no |
| vault\_output\_elasticsearch\_service\_name | Service name in Consul to lookup Elasticsearch URLs | `string` | `"elasticsearch"` | no |
| vault\_output\_elastisearch | Enable metrics output to Elasticsearch | `bool` | `false` | no |
| vault\_output\_prometheus | Create a Prometheus Client to serve the metrics for a Prometheus server to scrape | `bool` | `false` | no |
| vault\_output\_prometheus\_service\_cidrs | List of CIDRs that the Prometheus client will permit scraping. Remember to allow 127.0.0.1/32 for Consul health checks. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]<br></pre> | no |
| vault\_output\_prometheus\_service\_name | Name of the service to advertise in Consul | `string` | `"prometheus-client"` | no |
| vault\_output\_prometheus\_service\_port | Port of the Prometheus Client | `number` | `9273` | no |

## Outputs

No output.

