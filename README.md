# Terraform modules

Some reusable Terraform modules.

## [Core](modules/core)

This module sets up a VPC, and a Consul and Nomad cluster to allow you to run applications on.

## Traefik

Built on the core module, this module provisions load balancers on top of a Traefik reverse proxy
to expose your applications running on your Nomad cluster to the internet.

(Coming soon)
