# Consul and Vault AMI

AMI with Vault and Consul binaries installed. DNSmasq is also configured to use the local
Consul agent as its DNS server.

This is based on this [example](https://github.com/hashicorp/terraform-aws-vault/tree/master/examples/vault-consul-ami).

## Pre-requisites

### AWS KMS Requirement

1. Refer to the [`ca`](ca/README.md) for instructions on how to setup a CA with the associated keys.
1. ???


## Configuration Options

See [this page](https://www.packer.io/docs/templates/user-variables.html) for more information.

- `ami_base_name`: Base name for the AMI image. The timestamp will be appended
- `aws_region`: AWS Region
- `subnet_id`: ID of subnet to run the builder instance in
- `temporary_security_group_source_cidr`: Temporary CIDR to allow SSH access from
- `associate_public_ip_address`: Associate to `true` if the machine provisioned is to be connected via the internet
- `ssh_interface`: One of `public_ip`, `private_ip`, `public_dns` or `private_dns`. If set, either the public IP address, private IP address, public DNS name or private DNS name will used as the host for SSH. The default behaviour if inside a VPC is to use the public IP address if available, otherwise the private IP address will be used. If not in a VPC the public DNS name will be used.
- `nomad_version`: Version of Nomad to install
- `consul_module_version`: Version of the [Terraform Consul](https://github.com/hashicorp/terraform-aws-consul) repository to use
- `nomad_module_version`: Version of the [Nomad Module](https://github.com/hashicorp/terraform-aws-nomad) to use.
- `consul_version`: Version of Consul to install
- `docker_version`: Version of docker to install.

## Building Image

```bash
packer build \
    -var-file=vars.json \
    packer.json
```
