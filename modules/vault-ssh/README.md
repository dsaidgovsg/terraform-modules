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

You can update the servers for Consul and Nomad as you would do usually. Remember to do this
one by one, especially for Consul because if more servers than the Raft consensus that Consul uses
goes down, the Consul cluster will become unavailable and new servers will not be able to configure
themselves.

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

### Additional things you need to provision

This module does not create the policies that allow users to access the SSH secrets engine.
Thus, by default, no user except for root token holders will be able to access the key signing
facility.

For example, to allow a user to access Nomad clients mounted at `ssh_nomad_client` with the
`default` role, the following policy would work:

```hcl
path "ssh_nomad_client/sign/default" {
  capabilities = ["create", "update"]
}
```

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

## Additional Server Types

If you have a new "server type" or a different category of servers to control access to, you can
make use of the automated bootstrap and configuration that this repository. You can always configure
`sshd` manually if you elect not to do so.

For example, you might want to add a separate cluster of [Nomad clients](../nomad-clients)
and have their SSH access control be done separately.

The following pre-requisites must be met when you want to make use of the automation:

- You should install the bootstrap script using the [Ansible role](../core/packer/roles/install-ssh-script/) that is included by default using the default Packer images for the Core AMIs.
- Your AMI must have Consul installed and configured to run Consul agent. Installation of Consul agent can be done using this [module](https://github.com/hashicorp/terraform-aws-consul/tree/master/modules/install-consul) and Consul Agent can be started and run using this [module](https://github.com/hashicorp/terraform-aws-consul/tree/master/modules/run-consul).
- You need to mount a new instance of the Vault SSH secrets engine.
- You need to create the appropriate keys in Consul KV store so that the bootstrap script will have the necessary information to bootstrap.
- You will need to run the [bootstrap script](../core/packer/roles/install-ssh-script/files/configure.sh) in the instance at least once **after Consul Agent** is configured and running. By default, the script is installed to `/opt/vault-ssh` by the Ansible role. You can then run `/opt/vault-ssh --type ${server_type}`. Use the `--help` flag for more information.
- You will need to write the appropriate policies for your users to access the new secrets engine and its role.

For more information and examples, refer to the Packer templates and `user_data` scripts for
the various types of servers in the [core module](../core).

### Mounting a new instance of the SSH Secrets Engine

This module has a [sub-module](ssh-engine) that can facilitate this process.

### Consul KV Values

The default [bootstrap script](../core/packer/roles/install-ssh-script/files/configure.sh) looks
under the path `${prefix}vault-ssh/${server_type}`. The default prefix is `terraform/`.

First, it looks to see if `${prefix}vault-ssh/${server_type}/enabled` is set to `yes`.

Next, it looks for the path where the SSH secrets engine is mounted at the key
`${prefix}vault-ssh/${server_type}/path`.

### Terraform example

The example below will show how you can configure the SSH secrets engine and values needed in
Consul:

```hcl
module "additional_nomad_clients" {
  source = "./ssh-engine"

  enabled     = "yes"
  path        = "additional_nomad_clients"
  description = "Additional Nomad Client"

  ssh_user  = "..."
  ttl       = "..."
  max_ttl   = "..."
  role_name = "additional_nomad_clients"
}

resource "consul_key_prefix" "nomad_client" {
  depends_on = ["module.additional_nomad_clients"]

  path_prefix = "${var.consul_key_prefix}vault-ssh/additional_nomad_clients/"

  subkeys {
    enabled = "yes"
    path    = "additional_nomad_clients"
  }
}

```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| consul_enable | Enable SSH Certificate signing on Consul servers. The Consul servers will also install the CA     from Vault automatically. | string | `true` | no |
| consul_key_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has         been applied. If you change this, you have to update the         `nomad_vault_integration_consul_prefix` variable in the core module as well. | string | `terraform/` | no |
| consul_path | Path for Consul servers SSH access | string | `ssh_consul` | no |
| max_ttl | Max TTL for certificate renewal | string | `86400` | no |
| nomad_client_enable | Enable SSH Certificate signing on Nomad clients. The Nomad clients will also install the CA     from Vault automatically. | string | `true` | no |
| nomad_client_path | Path for Nomad clients SSH access | string | `ssh_nomad_client` | no |
| nomad_server_enable | Enable SSH Certificate signing on Nomad servers. The Nomad servers will also install the CA     from Vault automatically. | string | `true` | no |
| nomad_server_path | Path for Nomad servers SSH access | string | `ssh_nomad_server` | no |
| role_name | Name of role for each of the types of instances. | string | `default` | no |
| ssh_user | SSH user to allow SSH access | string | `ubuntu` | no |
| ttl | TTL for the certificate in seconds | string | `300` | no |
| vault_enable | Enable SSH Certificate signing on Vault servers. The Vault servers will also install the CA     from Vault automatically. | string | `true` | no |
| vault_path | Path for Vault servers SSH access | string | `ssh_vault` | no |
