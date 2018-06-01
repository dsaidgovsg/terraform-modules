# Terraform modules

Some reusable Terraform modules.

## [Core](modules/core)

This module sets up a VPC, and a Consul and Nomad cluster to allow you to run applications on.

## [AWS Authentication](modules/aws-auth)

This module configures Vault to accept authentication via EC2 instance metadata. This is required
for use with some of the Vault integration modules.

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

## [Docker Authentication](modules/docker-auth)

This module serves as a post-bootstrap addon for the Core Module. It allows you to configure Nomad
clients to authenticate with private Docker registries.
