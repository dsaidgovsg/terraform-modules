# `td-agent` module

This module allows enabling of `td-agent` service for log forwarding.

## Requirements

- [Core](../core) module

If you are using the provided configuration:

- [Elasticsearch](../elasticsearch)
- [Fluentd](../fluentd)

## Usage

When this module is provisioned, the default `user_data` scripts provided by the Core module will
start `td-agent` automatically and configure it. This applies to the `consul`, `nomad_client`, `nomad_server` and `vault` AMIs. If you want to use your custom `user_data`, see the section below.

When used with the default Packer templates, you should provide a
[Jinja template](http://jinja.pocoo.org/) with the `td_agent_config_file` Packer variable. To
provide the values for your Jinja Template, you can provide a YAML file with the values with the
`td_agent_config_vars_file` Packer variable.

It is perfectly fine to have the `td_agent_config_file` not contain any Jinja Template clauses. You
should be careful of using the `{{` and `}}` delimiters in your template files, though.

### Example Configuration

The directory contains some example configuration that you might find useful. The example
configuration will forward logs to the fluentd service provisioned by the [Fluentd](../fluentd)
module.

In particular, the example configuration files are:

- [`config/template/td-agent.conf`](conf/template/td-agent.conf) is the template configuration file
- [`config/consul/td-agent-vars.yml`](config/consul/td-agent-vars.yml) is the variable file for Consul servers
- [`config/nomad_servers/td-agent-vars.yml`](config/nomad_servers/td-agent-vars.yml) is the variable file for Nomad servers
- [`config/nomad_clients/td-agent-vars.yml`](config/nomad_clients/td-agent-vars.yml) is the variable file for Nomad Clients
- [`config/vault/td-agent-vars.yml`](config/vault/td-agent-vars.yml) is the variable file for Vault servers

Provide the variables to the Packer template variables. For example, to build the `Consul` AMI:

```bash
packer build \
  -var td_agent_config_file="config/template/td-agent.conf" \
  -var td_agent_config_vars_file="config/consul/td-agent-vars.yml" \
  .../consul.json
```

#### Tagging

The following services will be are tagged as:

- Consul: `services.consul`
- Consul Template: `services.consul-template`
- Nomad Servers and Clients: `services.nomad`
- Vault: `services.nomad`

The audit logs from Vault are in JSON format and will be parsed into keys. All the parsed keys from
Vault will be prefixed with `vault.`.

Additionally, the following syslog identifier from `systemd` will be forwarded and tagged:

- `cron`: `system.cron`
- `td-agent`: `system.td-agent`
- `telegraf`: `system.telegraf`
- `sshd`: `system.sshd`
- `sudo`: `system.sudo`

### Custom User Data

You should copy your `td-agent` configuration file into `/etc/td-agent/td-agent.conf` of your AMI,
and run `/opt/run-td-agent --type <service_type>` in the user data to start the service with the
custom configuration.

### Example usage

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

## Additional Server Types or Custom User Data

If you have a new "server type" or a different category of servers to forward logs, you can make
use of the automated bootstrap and configuration from this repository. You can always configure
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
