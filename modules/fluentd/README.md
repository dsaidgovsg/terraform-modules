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
out files to the `alloc/config` or `secrets/config` directories, depending on the
sensitivity of your data. All the file names must end with `.conf`.

The default fluentd config will
[`@include`](https://docs.fluentd.org/v0.12/articles/config-file#(6)-re-use-your-config:-the-%E2%80%9C@include%E2%80%9D-directive)
files from secrets first before the non-secrets file **before** the rest of the configuration.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_blocks | Additional blocks to be added to the Jobspec | string | `` | no |
| aws_region | Region of AWS for which this is deployed | string | `ap-southeast-1` | no |
| consul_key_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has         been applied. If you change this, you have to update the         `integration_consul_prefix` variable in the core module as well. | string | `terraform/` | no |
| elasticsearch_hostname | Host name of Elasticsearch | string | - | yes |
| elasticsearch_port | Port number of Elasticsearch | string | - | yes |
| enable_file_logging | Enable logging to file on the Nomad jobs. Useful for debugging, but not really needed for production | string | `false` | no |
| es6_support | Set to `true` if you are using Elasticsearch 6 and above to support the removal of mapping types (https://www.elastic.co/guide/en/elasticsearch/reference/current/removal-of-types.html) | string | `false` | no |
| fluentd_conf_file | Rendered fluentd configuration file | string | `alloc/config/fluent.conf` | no |
| fluentd_count | Number of copies of Fluentd to run | string | `3` | no |
| fluentd_force_pull | Force pull an image. Useful if the tag is mutable. | string | `false` | no |
| fluentd_image | Docker image for fluentd | string | `govtechsg/fluentd-s3-elasticsearch` | no |
| fluentd_match | Tags that fluentd should output to S3 and Elasticsearch | string | `app.** docker.** services.** system.** vault**` | no |
| fluentd_port | Port on the Docker image in which the TCP interface is exposed | string | `4224` | no |
| fluentd_tag | Tag for fluentd Docker image | string | `1.2.5-latest` | no |
| log_vault_policy | Name of the Vault policy to allow creating AWS credentials to write to Elasticsearch and S3 | string | `fluentd_logger` | no |
| log_vault_role | Name of the Vault role in the AWS secrets engine to provide credentials for fluentd to write to Elasticsearch and S3 | string | `fluentd_logger` | no |
| logs_s3_abort_incomplete_days | Specifies the number of days after initiating a multipart upload when the multipart upload must be completed. | string | `7` | no |
| logs_s3_bucket_name | Name of S3 bucket to store logs for long term archival | string | `` | no |
| logs_s3_enabled | Enable to log to S3 | string | `true` | no |
| logs_s3_glacier_transition_days | Number of days before logs are transitioned to IA. Must be > var.logs_s3_ia_transition_days + 30 days | string | `365` | no |
| logs_s3_ia_transition_days | Number of days before logs are transitioned to IA. Must be > 30 days | string | `90` | no |
| logs_s3_policy | Name of the IAM policy to provision for write access to the bucket | string | `LogsS3Write` | no |
| logs_s3_storage_class | Default storage class to store logs in S3. Choose from `STANDARD`, `REDUCED_REDUNDANCY` or `STANDARD_IA` | string | `STANDARD` | no |
| node_class | Node class for Nomad clients to constraint the jobs to. Use this with `node_class_operator`. The default matches everything. | string | `.?` | no |
| node_class_operator | Nomad constrant operator (https://www.nomadproject.io/docs/job-specification/constraint.html#operator) to use for restricting Nomad clients node class. Use this with `node_class`. The default matches everything. | string | `regexp` | no |
| nomad_azs | AZs which Nomad is deployed to. If left empty, the list of AZs from this region will be used | string | `<list>` | no |
| tags | Tags to apply to resources | string | `<map>` | no |
| vault_sts_path | If logging to S3 is enabled, provide to the path in Vault in which the AWS Secrets Engine is mounted | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| jobspec | Rendered jobspec |
| s3_arn | ARN of the S3 bucket created |
| s3_iam_arn | ARN of the IAM Policy document for S3 access |
