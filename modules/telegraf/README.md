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
}

...
```

You should copy your Telegraf configuration file into `/etc/telegraf/telegraf.conf`, and run
`/opt/run-telegraf --type <service_type>` in the user data to start the service with the custom
configuration.

If you wish to apply interpolation from `consul-template`, you may instead copy the configuration
file to `/etc/telegraf/telegraf.conf.template`. `run-telegraf` will automatically detect this file
and apply template interpolation, unless `--skip-template` is explicitly set for `run-telegraf`.
