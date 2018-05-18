# Consul and Vault AMI

AMI with Vault and Consul binaries installed. DNSmasq is also configured to use the local Consul
agent as its DNS server.

This is based on this
[example](https://github.com/hashicorp/terraform-aws-vault/tree/master/examples/vault-consul-ami).

## Pre-requisites

All the following commands to run are assumed to run in this `vault/` directory.

### Generate certificates

You will need to have a TLS certificate generated for vault. This usually requires you to have
generated an existing CA. Refer to
[`ca`](../../ca/README.md) for instructions on how to setup a CA with the associated keys.

For example, we will generate the certificate to the `vault/cert` directory:

```bash
# Generate key pair and CSR
cfssl genkey -config "../../ca/config.json" \
    -profile peer ../../ca/vault-cert/csr.json \
    | cfssljson -bare cert/cert
```

At this point, you must have decrypted the AWS-KMS encrypted CA private key (i.e. `ca.key` to
`ca-key.pem`) so that the CA private key can be used to sign the CSR.

Copy the true `ca.pem` and `ca.key` into `../../ca/root/` first, and perform the decryption step as
shown in the
[guide](../../ca/README.md#Decrypt-the-private-key). If the above two files are present, simply run
the below adapted command to get back the original CA private key:

```bash
aws kms decrypt \
    --ciphertext-blob fileb://../../ca/root/ca.key \
    --output text \
    --query Plaintext \
    --cli-input-json file://../../ca/root/cli.json \
| base64 --decode \
> ../../ca/root/ca-key.pem
```

With the original CA private key in place, sign the CSR with the following:

```bash
# Sign the CSR
cfssl sign -ca "../../ca/root/ca.pem" \
    -ca-key "../../ca/root/ca-key.pem" \
    -config "../../ca/config.json" \
    -profile peer \
    cert/cert.csr \
    | cfssljson -bare cert/cert
```

After you have generated the certificate, you will need to encrypt the private key of the
certificate before we copy it over to the AMI.

#### Encrypting the private key

We will use the [`kms-aes`](https://github.com/GovTechSG/kms-aes) Ansible playbooks and roles to
handle the encryption and decryption.

Checkout the repository to a directory and follow the instructions according to the
[Vault playbook](https://github.com/GovTechSG/kms-aes#vault-playbook).

For example, with the provided example `cli.json` and our `terraform` KMS key, we can do the
following to generate a data encryption key and to encrypt our certificate:

```bash
ansible-playbook \
    -i "localhost," \
    -c "local" \
    -t "generate_key,encrypt" \
    -e "key_id=alias/terraform" \
    -e "cli_json=$(pwd)/cert/cli.json" \
    -e "key_output=$(pwd)/cert/aes.key" \
    -e "vault_file=$(pwd)/cert/cert-key.pem" \
    -e "encrypted_vault_file=$(pwd)/cert/cert.key" \
    /path/to/playbook/vault.yml
```

This will output the encrypted keys and other files to their default location. Otherwise, you can
configure the path to the keys based on the options listed in the next section.

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
- `vault_version`: Version of Vault to install
- `consul_module_version`: Version of the
  [Terraform Consul](https://github.com/hashicorp/terraform-aws-consul) repository to use
- `vault_module_version`: Version of the
  [Vault Module](https://github.com/hashicorp/terraform-aws-vault) to use.
- `vault_ui_enable`: Enable UI for Vault or not. Defaults to `true`.
- `consul_version`: Version of Consul to install
- `consul_key`: Key in Consul to store Vault HA information in
- `tls_cert_file_src`: Path to the certificate file for Vault to use. This defaults to
  `cert/cert.pem` if you used the instructions above.
- `encrypted_tls_key_file_src`: Encrypted private key for the certificate. This defaults to
  `cert/cert.key` if you used the instructions above.
- `encrypted_aes_key_src`: AES data key used to encrypt the private key, which is in turned
  encrypted by AWS KMS. Defaults to `cert/aes.key` if you used the instructions above.
- `cli_json_src`: The AWS CLI JSON file used to encrypt the AES key. This defaults to
  `cert/cli.json` if you used the instructions above.
- `ca_certificate`: Path to the CA certificate you have generated to install on the machine. Set to
  empty to not install anything.

## Building Image

```bash
packer build packer.json
```
