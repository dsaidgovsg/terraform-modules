# Nomad clients AMI

AMI with Nomad and Consul binaries installed. DNSmasq is also configured to use the local
Consul agent as its DNS server.

This is based on this
[example](https://github.com/hashicorp/terraform-aws-nomad/tree/master/examples/nomad-consul-ami).

## Pre-requisite

### Certificate Authority

As part of the pre-requisites, you should already have generated certificates for a CA and,
a certificate for Consul. You should install the certificate for Consul by pointing Packer to the
path of the Certificate and CA.

## Configuration Options

See [this page](https://www.packer.io/docs/templates/user-variables.html) for more information.

- `ami_base_name`: Base name for the AMI image. The timestamp will be appended
- `aws_region`: AWS Region
- `subnet_id`: ID of subnet to run the builder instance in
- `temporary_security_group_source_cidr`: Temporary CIDR to allow SSH access from
- `associate_public_ip_address`: Associate to `true` if the machine provisioned is to be connected
  via the internet
- `ssh_interface`: One of `public_ip`, `private_ip`, `public_dns` or `private_dns`. If set, either
  the public IP address, private IP address, public DNS name or private DNS name will used as the
  host for SSH. The default behaviour if inside a VPC is to use the public IP address if available,
  otherwise the private IP address will be used. If not in a VPC the public DNS name will be used.
- `nomad_version`: Version of Nomad to install
- `consul_module_version`: Version of the
  [Terraform Consul](https://github.com/hashicorp/terraform-aws-consul) repository to use
- `nomad_module_version`: Version of the
  [Nomad Module](https://github.com/hashicorp/terraform-aws-nomad) to use.
- `consul_version`: Version of Consul to install
- `docker_version`: Version of docker to install.
- `vault_version`: Version of Vault to install
- `vault_module_version`: Version of the
  [Vault Module](https://github.com/hashicorp/terraform-aws-vault) to use.
- `td_agent_config_file`: Path to `td-agent` config file to template copy from. Install `td-agent`
  if path is non-empty.
- `ca_certificate`: Path to the CA certificate you have generated to install on the machine. Set to
  empty to not install anything.

## Building Image

```bash
packer build \
    -var-file=vars.json \
    packer.json
```
