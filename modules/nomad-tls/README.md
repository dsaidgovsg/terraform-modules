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



### Bootstrapping an existing cluster with downtime

This method is easier and *will* result in jobs being down momentarily. Before the initial
application of this module, you **must** set the required variable `bootstrap` to `no`.

You can now proceed to `terraform apply`.

#### Nomad Servers

After applying, you should replace your Nomad servers one by one. You can do this by terminating the
Nomad servers one by one as described in the Core module's instructions.

Once a quorum of Nomad servers are TLS enabled, TLS will be enabled on the entire cluster:

- The ELB provisioned by the Core module will stop to work (as will the endpoint you have configured) and we will have to update the `nomad_server_protocol` variable in the Core module and applying the changes to the ELB.
- Your clients will now be unable to heartbeat and your jobs will be "lost".

#### Nomad Clients

You can now replace your Nomad clients all at once by terminating all of them for ASG to replace.
Nomad server should then reschedule the jobs on the new nodes coming online.

### Bootstrapping an existing cluster without downtime

Nomad documentation
[suggests](https://www.nomadproject.io/guides/securing-nomad.html#switching-an-existing-cluster-to-tls)
some steps to turn on TLS for an existing cluster. This module will help facilitate this process.

We will be taking the unusual step of updating the Nomad clients in place in order to
reduce downtime. You might want to review all the steps in this section first before proceeding.

Before the initial application of this module, you **must** set the required variable `bootstrap`
to `yes`. This will set the `heartbeat_grace` setting in Nomad to `1h` so that your jobs will not
be "lost".

You can now proceed to `terraform apply`.

#### Nomad Servers



```bash
sudo /opt/consul-template/bin/run-consul-template \
    --server-type nomad_server \
    --dedup-enable \
    --syslog-enable

sudo /opt/nomad/bin/configure --server

sudo supervisorctl restart nomad
```


Once a quorum of Nomad servers are TLS enabled, TLS will be enabled on the entire cluster:

- The ELB provisioned by the Core module will stop to work (as will the endpoint you have configured) and we will have to update the `nomad_server_protocol` variable in the Core module and applying the changes to the ELB.
- Your clients will now be unable to heartbeat and you will have one hour before the jobs are declared "lost".

#### Nomad Clients

To prevent any "lost" jobs, we will have to update the configuration on the Nomad Clients in place
first.

The clients retrieve Vault tokens using the [aws-auth](../aws-auth) authentication method.
Re-authentication of the clients is
[disabled](https://www.vaultproject.io/docs/auth/aws.html#client-nonce) by default. Because we have
now added a new policy to the token issued to Nomad clients, we will have to retrieve a new Vault
Token for the clients to update them in place. Before we can do that, however, we will have to
[delete](https://www.vaultproject.io/api/auth/aws/index.html#delete-identity-whitelist-entries)
the instance whitelist in Vault.

For each Instance ID (`i-xxxxxx`) for your client, you will have to run the following (assuming the
AWS authentication is mounted at `aws`):

```bash
VAULT_TOKEN="..." vault delete auth/aws/identity-whitelist/i-xxxxxx

```

Then, you will have to SSH into the Nomad clients and assuming no changes to the core integration
variables, we can simply run:

```bash
# Retrieve new Vault token and reconfigure Consul-Template
sudo /opt/consul-template/bin/run-consul-template \
    --server-type nomad_client \
    --dedup-enable \
    --syslog-enable

# Assuming no defaults are changed
sudo /opt/nomad/bin/configure --client

# Might have to do this several times
sudo supervisorctl restart nomad

# Otherwise, you can find more information on the flags using
/opt/nomad/bin/configure --help
```

You should see your Nomad clients come online.


bootstrap off
