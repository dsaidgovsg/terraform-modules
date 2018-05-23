# Terraform modules

Some reusable Terraform modules.

## [Core](modules/core)

This module sets up a VPC, and a Consul and Nomad cluster to allow you to run applications on.

## [Nomad Vault Integration](modules/nomad-vault-integration)

This module serves as a post-bootstrap addon for the Core Module. It integrates Vault into Nomad
so that jobs may acquire secrets from Vault.

## [Nomad ACL](modules/nomad-acl)

This module serves as a post-bootstrap addon for the Core Module. This enables
[ACL](https://www.nomadproject.io/guides/acl.html) for Nomad, where Nomad ACL tokens can be
retrieved from Vault.

## [Vault SSH](modules/vault-ssh)

We can use Vault's
[SSH secrets engine](https://www.vaultproject.io/docs/secrets/ssh/signed-ssh-certificates.html) to
generate signed certificates to access your machines via SSH.

## [Traefik](modules/traefik)

This module serves as a post-bootstrap addon for the Core Module. This module provisions
load balancers on top of a Traefik reverse proxy to expose your applications running on your
Nomad cluster to the internet.
