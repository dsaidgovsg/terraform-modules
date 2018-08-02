# Helper Telegraf Module

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| consul_key_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has         been applied. If you change this, you have to update the         `integration_consul_prefix` variable in the core module as well. | string | `terraform/` | no |
| core_integration | Enable integration with the `core` module by setting some values in Consul so         that the user_data scripts in core know that this module has been applied | string | `true` | no |
| enabled | Enable Telegraf for this server type | string | `true` | no |
| output_elasticsearch_service_name | Service name in Consul to lookup Elasticsearch URLs | string | `elasticsearch` | no |
| output_elastisearch | Enable metrics output to Elasticsearch | string | `false` | no |
| path | Path after `consul_key_prefix` to write keys to | string | `telegraf/` | no |
| server_type | Server type | string | - | yes |
