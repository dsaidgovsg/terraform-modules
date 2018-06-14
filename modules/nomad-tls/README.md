# Nomad TLS

This module enabled [TLS](https://www.nomadproject.io/guides/securing-nomad.html) for Nomad
clusters.

## Warning

Applying this module can result in jobs being lost and rescheduled. You should proceed with care and
during a time where jobs downtime can be tolerated.

## Pre-requisites

You must have Terraformed the [core](../core) module first. In addition, you must have at least
initialised and unsealed the Vault servers.

Instead of generating a Vault Token by hand while configuring Nomad, we instead choose to configure
Vault to enable the [AWS authentication method](https://www.vaultproject.io/docs/auth/aws.html) so
that Nomad servers instance will be able to retrieve a token on first boot purely by authenticating
with Vault via their Instance Profile.

You **must** also provision this with the [aws-auth](../aws-auth) module. You **must** give the
`nomad_server` and `nomad_client` token roles in `aws-auth` the `nomad_server_tls` and
`nomad_client_tls` policies respectively.

You can use both modules in the same Terraform module to provision to satisfy the requirements.
For example:

```hcl

module "nomad_tls" {
    source = "..."

    # ...
}

module "aws_auth" {
    source = "..."

    # ...

    # Attach policy to allow creation of tokens for Nomad servers and clients
    nomad_server_policies = ["...", "${module.nomad_tls.server_policy_name}"]
    nomad_client_policies = ["...", "${module.nomad_tls.client_policy_name}"]
}

```

### Nomad Gossip Key

You must first generate a gossip key for Nomad. You can use the `nomad operator keygen` command.
Then, you must provide the key in the `gossip_key` variable. We recommend that you do not store this
key unencrypted in your Terraform files. Instead, you might want to encrypt it.

For example, you can use AWS KMS to encrypt the key, and then have Terraform decrypt it at apply
time using the [`aws_kms_secret`](https://www.terraform.io/docs/providers/aws/d/kms_secret.html)
data source.

You must also provide a path to the a key-value store for Nomad to store and read the key from.
Provide the path in the `gossip_path` variable.

## Vault Provider

Refer to the [documentation](https://www.terraform.io/docs/providers/vault/index.html) on the
Terraform Vault provider for details on how you can provide a Vault token for this Terraform
operation. In general, you might want to do this with a Root token.

## Consul Provider

Refer to the [documentation](https://www.terraform.io/docs/providers/consul/index.html)
on how to configure the ACL token for the provider if needed.

## Applying the Module

You will need to perform several steps to bootstrap and configure this endpoint.

### Bootstrapping an existing cluster

Nomad documentation
[suggests](https://www.nomadproject.io/guides/securing-nomad.html#switching-an-existing-cluster-to-tls)
some steps to turn on TLS for an existing cluster. This module will help facilitate this process.

Before the initial application of this module, you **must** set the required variable `bootstrap`
to `yes`. This will set the `heartbeat_grace` setting in Nomad to `1h` so that your jobs will not
be "lost".

You can now proceed to `terraform apply`.

After applying, you should replace your Nomad servers one by one. You will now need to change the
variable ``
