# Vault SSH

We can use Vault's
[SSH secrets engine](https://www.vaultproject.io/docs/secrets/ssh/signed-ssh-certificates.html) to
generate signed certificates to access your machines via SSH.

This module simply sets up the roles and CAs for you. You will still need to write the
appropriate policies for your users to generate the SSH certificates.

## Pre-requisite

You must have Terraformed the [core](../core) module first. In addition, you must have at least
initialised and unsealed the Vault servers.

## Vault Provider

Refer to the [documentation](https://www.terraform.io/docs/providers/vault/index.html) on the
Terraform Vault provider for details on how you can provide a Vault token for this Terraform
operation. In general, you might want to do this with a Root token.

## Applying the module

After you have applied this module, a key will be set in Consul's KV store. The default
`user_data` scripts of the Core's servers and clients will check for the presence of this
key in Consul to configure themselves accordingly.

You can update the servers for Consul and Nomad as you would do usually.

However, for Vault, you must take care to ensure the following while you are updating them:

- At least one Vault instance must be unsealed. Otherwise the new Vault servers cannot get the certificate.
- You must make sure to do this one instance at a time.
- Make sure you unseal new instances as they get are launched.

## What the Module Creates

There is no way to restrict the address that a signed key is able to access via SSH. In order to
allow more granularity in controlling the types of servers a user can SSH into, this module mounts
four SSH secrets engine, one for each type of servers provisioned by the core module:

- Consul Server
- Vault Server
- Nomad Server
- Nomad Client

You can use the mount paths for each secret engine to control access.

For each mount point, the role `default` is created.

## How to SSH

The [`vault ssh`](https://www.vaultproject.io/docs/commands/ssh.html) command is a helper script
to help automate the process.

In general, you will need to do the following:

- Sign your public key with the private key of the type of servers you want to access using Vault's API.
- SSH into the machine using a combination of your private key and the signed public key

For example, assuming the default mount point for Nomad Clients and we are using the default
SSH private key at `~/.ssh/id_rsa` and the public key at `~/.ssh/id_rsa.pub`,
we can do the following:

```bash
vault ssh \
    -mode ca \
    -mount-point "ssh_nomad_client" \
    -role default \
    ubuntu@x.x.x.x
```
