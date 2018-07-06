# Vault PKI

This module serves as a bootstrap addon for the Core module. It provisions the
[PKI secrets engine](https://www.vaultproject.io/docs/secrets/pki/index.html) in Vault. This PKI
secrets engine allows you to maintain an internal CA and allows Vault users to request for
certificates.

This module is required for some of the other Vault integration.

## Pre-requisites

You must have Terraformed the [core](../core) module first. In addition, you must have at least
initialised and unsealed the Vault servers.

## Vault Provider

Refer to the [documentation](https://www.terraform.io/docs/providers/vault/index.html) on the
Terraform Vault provider for details on how you can provide a Vault token for this Terraform
operation. In general, you might want to do this with a Root token.

## Core Module Integration

After you have applied this module, a key will be set in Consul's KV store. When you are building
the default Packer templates for Consul, Nomad Servers, Nomad Clients, or Vault, you can optionally
ask the template to install the CA certificate from the provisioned PKI secrets engine. The template
will then reference Consul for the URLs to obtain the CA certificate. See the individual Packer
template documentation for more details.

You might want to rebuild and update all the AMIs for your server so that your CA is installed onto
the AMI. This is necessary if you want to enable TLS for Nomad and Consul.
