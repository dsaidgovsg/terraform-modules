# AWS Authentication

This module configures Vault to accept authentication via
[AWS](https://www.vaultproject.io/docs/auth/aws.html). Specifically, it configures Vault to accept
authentication via EC2 instance metadata.

This module will create roles for each type of servers that is provisioned by the `core` module.

- Consul Servers
- Nomad Servers
- Nomad Clients
- Vault Servers

## Integration with other modules

This module is required for use with many other Vault integration modules. Refer to each
module's documentation on how they can be used together.

In particular, when provisioned, the `user_data` scripts of the Core modules will attempt to
retrieve a Vault token for use with [consul-template](https://github.com/hashicorp/consul-template)
and consul-template will attempt to renew the token.

## Pre-requisites

You must have Terraformed the [core](../core) module first. In addition, you must have at least
initialised and unsealed the Vault servers.

## Vault Provider

Refer to the [documentation](https://www.terraform.io/docs/providers/vault/index.html) on the
Terraform Vault provider for details on how you can provide a Vault token for this Terraform
operation. In general, you might want to do this with a Root token.
