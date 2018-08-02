# Telegraf module

This module allows enabling of `telegraf` service for metrics reporting. Meant to be used in
instances containing services `consul`, `nomad_client`, `nomad_server` and `vault`.

## Telegraf Configuration

By default, the Packer templates in the `Core` module will install Telegraf and the relevant
configuration script. A [default configuration template](../../roles/telegraf/files/telegraf.conf)
is copied to the AMI. The default configuration will discard all outputs.

You will need to provide your own configuration file to output to your desired sinks. In your Packer
template, you should copy your configuration files ending with `.conf` to the directory
`/etc/telegraf/telegraf.d/`.

If you are using the provided [Elasticsearch](../elasticsearch) or [Prometheus](../prometheus)
modules, you can set the appropriate variables in this module for outputs to these two modules to
be automatically configured.

## Example usage

```hcl
module "telegraf" {
  source = "github.com/GovTechSG/terraform-modules.git//terraform-modules/modules/telegraf"

  # Optional, default is true
  core_integration = true

  # Optional, default is terraform/
  consul_key_prefix = "terraform/"

  # Optional, default is true
  consul_enabled = true

  # Optional, default is true
  nomad_server_enabled = true

  # Optional, default is true
  nomad_client_enabled = true

  # Optional, default is true
  vault_enabled = true
}
```

## Defining Additional Server Types

If you have a new "server type" or a different category of servers to report, you can make use of
the automated bootstrap and configuration that this repository. You can always configure Telegraf
manually if you elect not to do so.

For example, you might want to add a separate cluster of [Nomad clients](../nomad-clients)
and have their metrics reported separately.

The following pre-requisites must be met when you want to make use of the automation:

- You should have installed Telegraf and the bootstrap using the [Ansible role](../core/packer/roles/telegraf) that is included by default using the default Packer images for the Core AMIs.
- Your AMI must have Consul installed and configured to run Consul agent. Installation of Consul agent can be done using this [module](https://github.com/hashicorp/terraform-aws-consul/tree/master/modules/install-consul) and Consul Agent can be started and run using this [module](https://github.com/hashicorp/terraform-aws-consul/tree/master/modules/run-consul).
- You will also need to provide the appropriate Telegraf configuration file while using the Ansible role.
- Define the key under the path `${prefix}telegraf/server_type/${server_type}/enabled` in Consul KV store with value `yes`. The default `prefix` is `terraform/`.
- If you want to enable automatic configuration of Elasticsearch, you will have to set the key `${prefix}telegraf/server_type/${server_type}/output/elasticsearch/enabled` to `yes` and set the key `${prefix}telegraf/server_type/${server_type}/output/elasticsearch/service_name` to the service name of Elasticsearch in Consul.
- Run the [bootstrap script](../core/packer/roles/telegraf/files/run-telegraf) to initialise Telegraf **after Consul agent has been started**. By default, the Ansible role installs the script to `/opt/run-telegraf`. For example, you can run `/opt/run-telegraf --type "${server_type}"`. Use the `--help` flag for more options.

For the required Consul keys, you can use the [helper module](server_type) to configure.

For more information and examples, refer to the Packer templates and `user_data` scripts for
the various types of servers in the [core module](../core).

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| consul_enabled | Enable Telegraf for Consul servers | string | `true` | no |
| consul_key_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has         been applied. If you change this, you have to update the         `integration_consul_prefix` variable in the core module as well. | string | `terraform/` | no |
| consul_output_elasticsearch_service_name | Service name in Consul to lookup Elasticsearch URLs | string | `elasticsearch` | no |
| consul_output_elastisearch | Enable metrics output to Elasticsearch | string | `false` | no |
| core_integration | Enable integration with the `core` module by setting some values in Consul so         that the user_data scripts in core know that this module has been applied | string | `true` | no |
| nomad_client_enabled | Enable Telegraf for Nomad clients | string | `true` | no |
| nomad_client_output_elasticsearch_service_name | Service name in Consul to lookup Elasticsearch URLs | string | `elasticsearch` | no |
| nomad_client_output_elastisearch | Enable metrics output to Elasticsearch | string | `false` | no |
| nomad_server_output_elasticsearch_service_name | Service name in Consul to lookup Elasticsearch URLs | string | `elasticsearch` | no |
| nomad_server_output_elastisearch | Enable metrics output to Elasticsearch | string | `false` | no |
| vault_enabled | Enable Telegraf for Nomad servers | string | `true` | no |
| vault_enabled | Enable Telegraf for Vault servers | string | `true` | no |
| vault_output_elasticsearch_service_name | Service name in Consul to lookup Elasticsearch URLs | string | `elasticsearch` | no |
| vault_output_elastisearch | Enable metrics output to Elasticsearch | string | `false` | no |
