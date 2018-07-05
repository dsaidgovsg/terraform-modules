# Nomad servers AMI

AMI with Nomad and Consul binaries installed. DNSmasq is also configured to use the local
Consul agent as its DNS server.

This is based on this
[example](https://github.com/hashicorp/terraform-aws-nomad/tree/master/examples/nomad-consul-ami).

## Pre-requisites

In addition to Ansible and Packer, you will need to install the following on your machine:

- [`python_consul`](https://github.com/cablehead/python-consul)

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
- `vault_version`: Version of Vault to install
- `vault_module_version`: Version of the
  [Vault Module](https://github.com/hashicorp/terraform-aws-vault) to use.
- `td_agent_config_file`: Path to `td-agent` config file to template copy from. Install `td-agent`
  if path is non-empty.
- `td_agent_config_vars_file`: Path to variables file to include for value interpolation for
  `td-agent` config file. Only included if the value is not empty. `include_vars` includes the
  variables into `config_vars` variable, i.e. if `xxx` value is defined in the variables file, you
  will need to do `{{ config_vars.xxx }}` to get the interpolation working.
- `ca_certificate`: Path to the CA certificate you have generated to install on the machine. Set to
  empty to not install anything.
- `extra_vars`: Additional variables to pass to Ansible via the [`-e`](https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html#cmdoption-ansible-playbook-e) flag. This is useful for additional variables that are available in the Ansible playbooks used to provision the packer images.

### Post Bootstrap Configuration

After the initial bootstrap, if you have applied one of the following post bootstrap modules,
you should set the following options to install whatever pre-requisite is required in the AMI:

- Vault PKI

The following options are common to all of the integrations:

- `consul_host`: The host for which Consul is accessible. Defaults to empty. If set to empty, all post bootstrap integration will be disabled.
- `consul_port`: Port where Consul is accessible. Defaults to 443
- `consul_scheme`: Scheme to access Consul. Defaults to "https"
- `consul_token`: ACL token to access Consul
- `consul_integration_prefix`: Prefix to look for Consul integration values. Do not change this unless you have also modified the values in the appropriate modules. Defaults to "terraform/"

## Building Image

If you have a `vars.json` variables file containing changes to the above variables, you may run:

```bash
packer build \
    -var-file=vars.json \
    packer.json
```

Otherwise if you wish to use the default variable values, simply run:

```bash
packer build packer.json
```

If you have enabled the post-bootstrap integration, you can use `terraform output` to get the URL
of your Consul servers. In this way, you can use the same command for pre and post bootstrap builds
of your AMI.

```bash
packer build \
    -var-file=vars.json \
    -var consul_host="$(terraform output consul_api_address || echo -n '')" \
    packer.json
```
