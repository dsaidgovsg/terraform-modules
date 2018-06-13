# `td-agent` module

This module allows enabling of `td-agent` service for metrics reporting. Meant to be used in
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
