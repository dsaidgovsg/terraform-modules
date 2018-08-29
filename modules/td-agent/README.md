# `td-agent` module

This module allows enabling of `td-agent` service for log forwarding. Meant to be used in
instances containing services `consul`, `nomad_client`, `nomad_server` and `vault`.

## Integration with `Core` module

This module is integrated with the `core` module to enable you to use both in conjunction
seamlessly.

## Example usage

```hcl
...

module "td-agent" {
  source = "../../../vendor/terraform-modules/modules/td-agent"

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

You should copy your `td-agent` configuration file into `/etc/td-agent/td-agent.conf`, and run
`/opt/run-td-agent --type <service_type>` in the user data to start the service with the custom
configuration.

If you wish to apply interpolation from `consul-template`, you may instead copy the configuration
file to `/etc/td-agent/td-agent.conf.template`. `run-td-agent` will automatically detect this file
and apply template interpolation, unless `--skip-template` is explicitly set for `run-td-agent`.

## Additional Server Types

If you have a new "server type" or a different category of servers to forward logs, you can make
use of the automated bootstrap and configuration that this repository. You can always configure
`td-agent` manually if you elect not to do so.

For example, you might want to add a separate cluster of [Nomad clients](../nomad-clients)
and have their logs forwarded separately.

The following pre-requisites must be met when you want to make use of the automation:

- You should have installed `td-agent` and the bootstrap using the [Ansible role](../core/packer/roles/td-agent) that is included by default using the default Packer images for the Core AMIs.
- Your AMI must have Consul installed and configured to run Consul agent. Installation of Consul agent can be done using this [module](https://github.com/hashicorp/terraform-aws-consul/tree/master/modules/install-consul) and Consul Agent can be started and run using this [module](https://github.com/hashicorp/terraform-aws-consul/tree/master/modules/run-consul).
- You will also need to provide the appropriate `td-agent` configuration file while using the Ansible role.
- Define the key under the path `${prefix}td-agent/${server_type}/enabled` in Consul KV store with value `yes`. The default `prefix` is `terraform/`.
- Run the [bootstrap script](../core/packer/roles/td-agent/files/run-td-agent) to initialise `td-agent` **after Consul agent has been started**. By default, the Ansible role installs the script to `/opt/run-td-agent`. For example, you can run `/opt/run-td-agent --type "${server_type}"`. Use the `--help` flag for more options.

For more information and examples, refer to the Packer templates and `user_data` scripts for
the various types of servers in the [core module](../core).

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| consul_enabled | Enable td-agent for Consul servers | string | `true` | no |
| consul_key_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has         been applied. If you change this, you have to update the         `integration_consul_prefix` variable in the core module as well. | string | `terraform/` | no |
| core_integration | Enable integration with the `core` module by setting some values in Consul so         that the user_data scripts in core know that this module has been applied | string | `true` | no |
| nomad_client_enabled | Enable td-agent for Nomad clients | string | `true` | no |
| nomad_server_enabled | Enable td-agent for Nomad servers | string | `true` | no |
| vault_enabled | Enable td-agent for Vault servers | string | `true` | no |
