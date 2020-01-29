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
configure your instances to forward logs to fluentd. It also match logs tagged with `docker.*` for
your Nomad jobs.

You can change the matched tags with the `fluentd_match` variable.

## Applying the module

There are some things to take note of before applying the module other than the requirements above.

### Fluentd port

Fluentd will statically bind itself to a port of your choose via the `fluentd_port` variable on your
Nomad clients.

In order for your applications to forward logs to your Fluentd servers, you will have to define
additional security group rules to your Nomad clients cluster.

### Elasticsearch Address and Port

If you provisioned Elasticsearch with the [elasticsearch module](../elasticsearch) module, you can
provide the address to Elasticsearch using the Consul service catalog.

For example:

```hcl
data "consul_catalog_service" "elasticsearch" {
  name = "elasticsearch"
}

module "fluentd" {
  # ...
  elasticsearch_hostname = "${data.consul_catalog_service.elasticsearch.service.0.address}"
  elasticsearch_port     = "${data.consul_catalog_service.elasticsearch.service.0.port}"
}

```

## Forwarding Logs

You can use the [td-agent module](../td-agent) along with the example configuration files to forward
logs from your Consul Servers, Noamd Servers, Nomad Clients, and Vault Servers to Fluentd.

If you would like to forward logs from your Nomad jobs, you might want to tag them with
`docker.XXX`.

For example, in your Jobspec, you can use:

```hcl
job "job" {
  # ...
  group "group" {
    # ...
    task "task" {
      # ...
      driver = "docker"

      config {
        logging {
          type = "fluentd"

          config {
            fluentd-address = "fluentd.service.consul:4224"
            tag             = "docker.job"
          }
        }
      }
    }
  }
}
```

## Additional Configuration

If you would like to add additional configuration to Fluentd, you can do so with the
`additional_blocks` variable. You can use the
[`template`](https://www.nomadproject.io/docs/job-specification/template.html) stanza to template
out files to the `alloc/additional` or `secrets/config` directories, depending on the
sensitivity of your data. All the file names must end with `.conf`.

The default fluentd config will
[`@include`](https://docs.fluentd.org/v0.12/articles/config-file#(6)-re-use-your-config:-the-%E2%80%9C@include%E2%80%9D-directive)
files from secrets first before the non-secrets file **before** the rest of the configuration.

## Inputs and Outputs

Refer to [INOUT.md](INOUT.md)
