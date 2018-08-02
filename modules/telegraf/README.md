# Telegraf module

This module allows enabling of `telegraf` service for metrics reporting. Meant to be used in
instances containing services `consul`, `nomad_client`, `nomad_server` and `vault`.

## Pre-requisites and integration

This module is integrated with the `core` module to enable you to use both in conjunction
seamlessly.

If you use the default Telegraf configuration file, metrics will be logged to the Elasticsearch
service provisioned in the [Elasticsearch module](../elasticsearch). You will need to provision the
module first.

Otherwise, if you want to output to other sinks, you will need to provide your own configuration
file.

## Telegraf Configuration

A [default configuration template](../../roles/telegraf/files/telegraf.conf) is copied to the AMI.
If you want to use your own configuration. you will have to provide the path to your configuration
file in the various Packer template variable `telegraf_config_file`.

The default configuration will log metrics to the Elasticsearch service provisioned by the
`elasticsearch` module.

## Example usage

```hcl
...

module "telegraf" {
  source = "../../../vendor/terraform-modules/modules/telegraf"

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

...
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
- Define the key under the path `${prefix}telegraf/${server_type}/enabled` in Consul KV store with value `yes`. The default `prefix` is `terraform/`.
- Run the [bootstrap script](../core/packer/roles/telegraf/files/run-telegraf) to initialise Telegraf **after Consul agent has been started**. By default, the Ansible role installs the script to `/opt/run-telegraf`. For example, you can run `/opt/run-telegraf --type "${server_type}"`. Use the `--help` flag for more options.

For more information and examples, refer to the Packer templates and `user_data` scripts for
the various types of servers in the [core module](../core).

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| consul_enabled | Enable Telegraf for Consul servers | string | `true` | no |
| consul_key_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has         been applied. If you change this, you have to update the         `integration_consul_prefix` variable in the core module as well. | string | `terraform/` | no |
| core_integration | Enable integration with the `core` module by setting some values in Consul so         that the user_data scripts in core know that this module has been applied | string | `true` | no |
| nomad_client_enabled | Enable Telegraf for Nomad clients | string | `true` | no |
| nomad_server_enabled | Enable Telegraf for Nomad servers | string | `true` | no |
| vault_enabled | Enable Telegraf for Vault servers | string | `true` | no |
