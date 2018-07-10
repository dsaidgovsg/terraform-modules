# Telegraf module

This module allows enabling of `telegraf` service for metrics reporting. Meant to be used in
instances containing services `consul`, `nomad_client`, `nomad_server` and `vault`.

## Integration with `Core` module

This module is integrated with the `core` module to enable you to use both in conjunction
seamlessly.

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

You should copy your Telegraf configuration file into `/etc/telegraf/telegraf.conf`, and run
`/opt/run-telegraf --type <service_type>` in the user data to start the service with the custom
configuration.

If you wish to apply interpolation from `consul-template`, you may instead copy the configuration
file to `/etc/telegraf/telegraf.conf.template`. `run-telegraf` will automatically detect this file
and apply template interpolation, unless `--skip-template` is explicitly set for `run-telegraf`.

## Additional Server Types

If you have a new "server type" or a different category of servers to report, you can make use of
the automated bootstrap and configuration that this repository. You can always configure Telegraf
manually if you elect not to do so.

For example, you might want to add a separate cluster of [Nomad clients](../nomad-clients)
and have their metrics reported separately.

The following pre-requisites must be met when you want to make use of the automation:

- You should have installed Telegraf and the bootstrap using the [Ansible role](../core/packer/roles/telegraf) that is included by default using the default Packer images for the Core AMIs.
- Your AMI must have Consul installed and configured to run Consul agent.
- You will also need to provide the appropriate Telegraf configuration file while using the Ansible role.
- Define the key under the path `${prefix}telegraf/${server_type}/enabled` in Consul KV store with value `yes`. The default `prefix` is `terraform/`.
- Run the bootstrap script to initialise Telegraf` **after Consul agent has been started**. By default, the Ansible role installs the script to `/opt/run-telegraf`. For example, you can run `/opt/run-telegraf --type "${server_type}"`. Use the `--help` flag for more options.

For more information and examples, refer to the Packer templates and `user_data` scripts for
the various types of servers in the [core module](../core).
