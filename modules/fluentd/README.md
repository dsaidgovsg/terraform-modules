# Fluentd

This module runs fluentd on Nomad to forward logs to Elasticsearch and (optionally) S3.

## Requirements

- [Core module](../core)
- [`nomad-vault-integration` module](../nomad-vault-integration) if writing to S3
- Elasticsearch cluster — You can optionally choose to use the [elasticsearch module](../elasticsearch) to run your cluster

### Vault

You must have initialised and provisioned the
[`nomad-vault-integration` module](../nomad-vault-integration). This is because the job would be
required to retrieve credentials to write to S3.

You must enable and configure the
[AWS Secrets Engine](https://www.vaultproject.io/docs/secrets/aws/index.html) to allow the Vault
and the job to retrieve credentials. This module will provision the appropriate Vault AWS Secrets
Engine role and the IAM policies required.

Provide the necessary paths to the module variables.

## Default settings

By default, `fluentd` is configured to match tags from logs sent from the example configuration
provided in the [`td-agent`](../td-agent) module. See the module for more information on how to
configure your instances to forward logs to fluentd.

You can change the matched tags with the `fluentd_match` variable.

## Applying the module

There are some things to take note of before applying the module other than the requirements above.

### Fluentd port

Fluentd will statically bind itself to a port of your choose via the `fluentd_port` variable on your
Nomad clients.

In order for your applications to forward logs to your Fluentd servers, you will have to define
additional security group rules to your Nomad clients cluster.
