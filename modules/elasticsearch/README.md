# Staging AWS Elasticsearch service

## Registered `consul` service name

The registered `consul` service name is `elasticsearch`, and the port used is
`443`.

The actual VPC service and port are registered in `consul`. Any other services
that require Elasticsearch service should always use the actual VPC service
name, since the service is hosted under SSL and the SSL certificate to accept is
registered under the VPC name (and not the `consul` service name).

## Terraform configuration

For `terraform`, you will need something like the following to get the AWS
Elasticsearch service name:

```hcl
provider "consul" {
    version = "~> 1.0"
    address = "${data.terraform_remote_state.core.consul_api}"
    scheme = "https"
    datacenter = "${var.aws_region}"
}

data "consul_catalog_service" "elasticsearch" {
    name = "${var.elasticsearch_consul_name}"
}

locals {
    elasticsearch_hostname = "${data.consul_catalog_service.elasticsearch.service.0.address}"
    elasticsearch_port = "${data.consul_catalog_service.elasticsearch.service.0.port}"
}

variable "aws_region" {
    default = "ap-southeast-1"
}

variable "elasticsearch_consul_name" {
    description = "Elasticsearch registered Consul service name"
    default = "elasticsearch"
}
```

## Accessing Kibana

This module also deploys a simple job in Nomad to redirect you to Kibana.

You can access Kibana at [https://kibana.locus.rocks](https://kibana.locus.rocks).

## Deployment steps

### Requirements

* Terraform
* Vault with
  [Vault token](https://github.com/datagovsg/l-cloud/tree/master/environments/staging/vault#vault-tokens)
* Nomad with
  [Nomad token](https://github.com/datagovsg/l-cloud/tree/master/environments/staging/vault#nomad)

### Extracted commands to run for Vault and Nomad tokens

Make sure you are on GDS AWS VPN first in order to enable access to
`vault.locus.rocks`. You may perform `nslookup vault.locus.rocks` and check if
the hostname can be resolved to an IP address first. If it does not, you should
fix the VPN connection first to make sure that the name resolution works.

To get Vault token:

```bash
vault login --address https://vault.locus.rocks \
    -method=ldap \
    -path=locus_ldap \
    username=<ldap_username>
```

To get Nomad token:

```bash
vault read \
    -address https://vault.locus.rocks \
    -field secret_id \
    locus_nomad/creds/developer \
    > ~/.nomad-token
```

### Commands to run

To get the service up and running from scratch (or update the service with
modifications), run the following:

```bash
NOMAD_TOKEN=$(cat ~/.nomad-token) terraform plan|apply|destroy
```
