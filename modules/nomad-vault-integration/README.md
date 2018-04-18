# Nomad Vault Integration

This module is an example on how you can setup integration between Vault and Nomad. Refer to
[this page](https://www.nomadproject.io/docs/vault-integration/index.html) for more information.

This is intended to be used alongside the [core](../core) module.

## Vault Provider

Refer to the [documentation](https://www.terraform.io/docs/providers/vault/index.html) on the
Terraform Vault provider for details on how you can provide a Vault token for this Terraform
operation. In general, you might want to do this with a Root token.

## Vault Token

Instead of generating a Vault Token by hand while configuring Nomad, we instead choose to configure
Vault to enable the [AWS authentication method](https://www.vaultproject.io/docs/auth/aws.html) so
that Nomad servers instance will be able to retrieve a token on first boot purely by authenticating
with Vault via their Instance Profile.
