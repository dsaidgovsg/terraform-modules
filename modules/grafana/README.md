# Grafana

This module deploys Grafana on top of the Nomad cluster deployed in the `Core` module. In addition,
it makes use of Vault store and retrieve secrets that are needed for Grafana to operate.

## Requirements

### Modules Required

- Core Module
- Traefik Module

### Additional Requirements

- Database (MySQL, or Postgresql)

### Optional Requirements

- Vault AWS Secrets engine
- Elasticsearch (via the module in this repository, or otherwise)
- Prometheus (via the module)

In addition, you will need to prepare the following secrets, as described in the sections below.

## Secrets

You will need to prepare some secrets before hand, and then provide them in Vault in one form or
another.

Remember to provision and provide this module with the appropriate Vault policies to access
these secrets.

### Database Credentials [REQUIRED]

You will need to store the database credentials in Vault for Grafana to access. You can either
use the [Key Value Store](https://www.vaultproject.io/docs/secrets/kv/index.html) for static
credentials, or the
[Database secrets engine](https://www.vaultproject.io/docs/secrets/databases/index.html).

In any case, the type of store you choose to use to provide the Nomad job with the credentials does
not matter. The job expects you to pass in a path to Vault that it will perform a `read` from,
and the data it expects should be in a key-value pair where the username is in the `username` key
and the password is in the `password` key.

If you are using the Database secrets engine, the data returned from Vault is in the right form.

If you are using the KV store, make sure you input your data in the right key-value format:

```json
{
    "username": "postgres",
    "password": "postgres"
}
```

### Admin Credentials [REQUIRED]

You will need to provide a set of default Admin username and passsword.

You can use [`random_string`](https://www.terraform.io/docs/providers/random/r/string.html) to
randomly generate the password and write it to Vault.

Alternatively, you can encrypt the password with AWS KMS to your code, and then use
[`aws_kms_secrets`](https://www.terraform.io/docs/providers/aws/d/kms_secrets.html) to decrypt it
at apply time.

You will need to provide the path in Vault for the job to retrieve the credentials. You should use
the KV store for this.

By default, the job will expect the credentials in this format:

```json
{
    "username": "admin",
    "password": "admin"
}
```

### AWS Credentials [OPTIONAL]

The job can automatically configure an
[AWS Cloudwatch](http://docs.grafana.org/features/datasources/cloudwatch/) data source if you
configure the path to an
[AWS secrets engine](https://www.vaultproject.io/docs/secrets/aws/index.html) in Vault that can
issue AWS credentials with the appropriate policies.

To enable this, configure the `cloudwatch_datasource_aws_path` variable.

### Additional Task Configuration

You can use the variable `additional_task_config` to write additional configuration for the Nomad
Job [`task`](https://www.nomadproject.io/docs/job-specification/task.html). Anything that is valid
in the `task` stanza can go into the variable.

For example, you can use the
[`template`](https://www.nomadproject.io/docs/job-specification/template.html) stanza to provision
more datasources or dashboards.

Write any provisioned datasource as individual `yaml` files to `secrets/provisioning/datasources/`.

Write any additional dashboard as individual `json` files to `alloc/dashboards/`.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_driver_config | Additional HCL config for the Task docker driver. | string | `` | no |
| additional_task_config | Additional HCL configuration for the task. See the README for more. | string | `` | no |
| aws_billing_dashboard | If the Cloudwatch data source is enabled, set this to automatically import a billing dashboard | string | `true` | no |
| aws_cloudwatch_dashboard | If the Cloudwatch data source is enabled, set this to automatically import a Cloudwatch dashboard | string | `true` | no |
| aws_region |  | string | `ap-southeast-1` | no |
| cloudwatch_datasource_aws_path | Path in Vault AWS Secrets engine to retrieve AWS credentials. Set to empty to disable. | string | `` | no |
| cloudwatch_datasource_name | Name of the AWS Cloudwatch data source | string | `Cloudwatch` | no |
| grafana_additional_config | Additional configuration. You can place Go templates in this variable to read secrets from Vault. See http://docs.grafana.org/auth/overview/ | string | `` | no |
| grafana_bind_addr | IP address to bind the service to | string | `0.0.0.0` | no |
| grafana_count | Number of copies of Grafana to run | string | `3` | no |
| grafana_database_host | Host name of the database | string | - | yes |
| grafana_database_name | Name of database for Grafana | string | `grafana` | no |
| grafana_database_port | Port of the database | string | - | yes |
| grafana_database_ssl_mode | For Postgres, use either disable, require or verify-full. For MySQL, use either true, false, or skip-verify. | string | - | yes |
| grafana_database_type | Type of database for Grafana. `mysql` or `postgres` is supported | string | - | yes |
| grafana_domain | Domain for Github/Google Oauth redirection. If not set, will use the first from `grafana_fqdns` | string | `` | no |
| grafana_entrypoints | List of Traefik entrypoints for the Grafana job | string | `<list>` | no |
| grafana_force_pull | Force pull an image. Useful if the tag is mutable. | string | `true` | no |
| grafana_fqdns | List of FQDNs to for Grafana to listen to | list | - | yes |
| grafana_image | Docker image for Grafana | string | `grafana/grafana` | no |
| grafana_job_name | Nomad job name for service Grafana | string | `grafana` | no |
| grafana_port | Port on the Docker image in which the HTTP interface is exposed. This is INTERNAL to the container. | string | `3000` | no |
| grafana_router_logging | Set to true for Grafana to log all HTTP requests (not just errors). These are logged as Info level events to grafana log. | string | `true` | no |
| grafana_tag | Tag for Grafana Docker image | string | `5.3.4` | no |
| grafana_vault_policies | List of Vault Policies for Grafana to retrieve the relevant secrets | list | - | yes |
| nomad_azs | AZs which Nomad is deployed to. If left empty, the list of AZs from this region will be used | string | `<list>` | no |
| nomad_clients_node_class | Job constraint Nomad Client Node Class name | string | - | yes |
| prometheus_datasource_name | Name of the Prometheus data source | string | `Prometheus` | no |
| prometheus_service | If set, will query Consul for the Prometheus service and retrieve the host and port of a Prometheus server | string | `` | no |
| session_config | A Go template string to template out the session provider configuration. Depends on the type of provider | string | `` | no |
| session_provider | Type of session store | string | `memory` | no |
| vault_admin_password_path | Path for the Go template to read the admin password | string | `.Data.password` | no |
| vault_admin_path | Path in Vault to retrieve the admin credentials | string | - | yes |
| vault_admin_username_path | Path for the Go template to read the admin username | string | `.Data.username` | no |
| vault_database_password_path | Path for the Go template to read the database password | string | `.Data.password` | no |
| vault_database_path | Path in Vault to retrieve the database credentials | string | - | yes |
| vault_database_username_path | Path for the Go template to read the database username | string | `.Data.username` | no |
