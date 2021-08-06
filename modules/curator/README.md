# Curator

This module runs [Curator](https://github.com/elastic/curator) as a Cron job in Nomad to clean up
old indices in your Elasticsearch cluster.

## Requirements

- Core
- Elasticsearch cluster — You can optionally choose to use the [elasticsearch module](../elasticsearch) to run your cluster

## Default settings

By default, `curator` is configured to match tags from logs sent from the example configuration
provided in the [`td-agent`](../td-agent) module. It also matches logs tagged with `docker.*` for
your Nomad jobs.

If you have additional custom prefixes or suffixes to match, use the `actions` submodule in this
module, as the matching behavior is controlled by Consul keys.

For example:
```hcl
module "sudo" {
  source = "github.com/dsaidgovsg/terraform-modules//modules/curator/action"

  key               = "sudo"
  disable           = var.sudo_disable
  age               = var.sudo_age
  prefix            = var.sudo_prefix
  consul_key_prefix = var.consul_key_prefix
}
```

## Docker Image

You should build a Docker image from the official [repository](https://github.com/elastic/curator)
and push it to your own Docker Registry. Then, configure the relevant entrypoints and arguments.

The default entrypoints and arguments assumes an image built from the official repository.

## Inputs and Outputs

Refer to [INOUT.md](INOUT.md)
