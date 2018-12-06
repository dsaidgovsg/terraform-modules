# Terraform modules

This repository contains a set of (opinionated) [Terraform](https://www.terraform.io/)
[modules](https://www.terraform.io/docs/modules/index.html) to provision HashiCorp's suite of tools
on AWS, including:

- [Consul](https://www.consul.io/): Service discovery, distributed key-value store, and service mesh
- [Nomad](https://www.nomadproject.io/): Scheduling
- [Vault](https://www.vaultproject.io/): secrets management

These tools are useful to deploy a basic infrastructure on the cloud for your developers to run
their applications and services.

To get started, see the [Core](modules/core) module. Some of the modules are optional and
add additional features after you have provisioned the Core module.

## Submodules

This repository has various submodules. When you are cloning it for the first time, make sure to
do so with

```bash
git clone --recursive https://github.com/GovTechSG/terraform-modules.git
```

To update an already cloned repository, you can do

```bash
git submodule update --init --recursive
```

## Modules

### [Core](modules/core)

This module sets up a VPC, and a Consul and Nomad cluster to allow you to run applications on.

### [AWS Authentication](modules/aws-auth)

This module configures Vault to accept authentication via EC2 instance metadata. This is required
for use with some of the Vault integration modules.

### [Nomad Vault Integration](modules/nomad-vault-integration)

This module serves as a post-bootstrap addon for the Core Module. It integrates Vault into Nomad
so that jobs may acquire secrets from Vault.

### [Nomad ACL](modules/nomad-acl)

This module serves as a post-bootstrap addon for the Core Module. This enables
[ACL](https://www.nomadproject.io/guides/acl.html) for Nomad, where Nomad ACL tokens can be
retrieved from Vault.

### [Vault SSH](modules/vault-ssh)

We can use Vault's
[SSH secrets engine](https://www.vaultproject.io/docs/secrets/ssh/signed-ssh-certificates.html) to
generate signed certificates to access your machines via SSH.

### [Traefik](modules/traefik)

This module serves as a post-bootstrap addon for the Core Module. This module provisions
load balancers on top of a Traefik reverse proxy to expose your applications running on your
Nomad cluster to the internet.

### [Docker Authentication](modules/docker-auth)

This module serves as a post-bootstrap addon for the Core Module. It allows you to configure Nomad
clients to authenticate with private Docker registries.

### [Vault PKI](modules/vault-pki)

This module serves as a bootstrap addon for the Core module. It provisions the
[PKI secrets engine](https://www.vaultproject.io/docs/secrets/pki/index.html) in Vault. This PKI
secrets engine allows you to maintain an internal CA and allows Vault users to request for
certificates.

This module is required for some of the other Vault integration.

### [Elasticsearch](modules/elasticsearch)

This modules serves as a post-bootstrap addon for the Core Module. This module adds managed AWS
Elasticsearch service (with Kibana). The module also allows integration with
[Traefik](modules/traefik) set-up, to allow redirect service to redirect users to the Kibana
visualisation UI with a more friendly named URL.

### [Curator](modules/curator)

This module runs [Curator](https://github.com/elastic/curator) as a Cron job in Nomad to clean up
old indices in your Elasticsearch cluster.

### [Lambda-api-gateway](modules/lambda-api-gateway)

This module sets up a Lambda function with a API Gateway trigger, secured with an API key authentication.

### [Telegraf](modules/telegraf)

This module sets up [Telegraf](https://www.influxdata.com/time-series-platform/telegraf/) service for collecting and reporting metrics. This is instances containing services `consul`, `nomad_client`, `nomad_server` and `vault`.

### [Td-Agent](modules/td-agent)

This module allows enabling of `td-agent`, the stable distrution package of [Fluentd](https://www.fluentd.org), for log forwarding. For
instances containing services `consul`, `nomad_client`, `nomad_server` and `vault`.

### [Nomad Clients](modules/nomad-clients)

This module sets up an additional cluster of Nomad clients after the initial bootstrap of the `core` module.

### [Vault App Policy](modules/vault-app-policy)

This module is an addon for adding application service policies to access key / value secrets stored in your already set-up Vault.

## [Fluentd](modules/fluentd)

This module runs Fluentd on Nomad to forward logs to Elasticsearch and (optionally) S3.

## [Vault Auto Unseal](modules/vault-auto-unseal)

Provisions additional resources to enable
[Vault Auto Unseal](https://www.vaultproject.io/docs/concepts/seal.html#auto-unseal) when used
with the Core module.

## Roles

Contains Ansible roles for installation of various services. For more details, check out the README
in the respective role directories.
