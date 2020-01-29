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

If you have custom prefix or suffix to define, consider using the `actions` submodule in this
module.

## Docker Image

You should build a Docker image from the official [repository](https://github.com/elastic/curator)
and push it to your own Docker Registry. Then, configure the relevant entrypoints and arguments.

The default entrypoints and arguments assumes an image built from the official repository.

## Inputs and Outputs

Refer to [INOUT.md](INOUT.md)
