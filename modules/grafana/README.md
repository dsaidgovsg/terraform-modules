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

## Inputs and Outputs

Refer to [INOUT.md](INOUT.md)
