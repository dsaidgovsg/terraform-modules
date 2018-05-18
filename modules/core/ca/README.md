# Self-signed Certificate Authority

This directory contains instruction on how to setup a CA to issues certificate for Vault, Consul and
Nomad to perform TLS communication, and finally to import an intermediate CA into Vault to issue
certificates for Nomad and other services.

1. [Create a new master key in AWS KMS](https://docs.aws.amazon.com/kms/latest/developerguide/create-keys.html)
1. Generate a key for the CA and create a cerficiate for the CA.
1. Encrypt the key with KMS.
1. (Optional) set up [Grants](https://docs.aws.amazon.com/kms/latest/developerguide/grants.html)
   for the KMS CMK.
1. Store the encrpyted key.
1. Renew CA with the same key.

The guide will make use of [`cfssl`](https://github.com/cloudflare/cfssl). All commands to run are
assumed to be done in this `ca/` directory.

If you are running on a recent `Ubuntu` machine, you can install `golang-cfssl` from `apt`
repository:

```bash
apt install golang-cfssl
```

Alternatively you can run this in an interactive `bash` shell in Docker container to simplify
operations:

```bash
docker run \
    --rm \
    -it \
    --entrypoint bash \
    -v `pwd`:/data \
    -u `id -u`:`id -g` \
    --name user \
    --workdir /data \
    cfssl/cfssl:1.3.2
```

Ignore the `I have no name!` user name display in the interactive shell.

Make sure that all commands (including the above ones) are run in `ca/`. The commands below will be
be compatible with either of the above methods used.

Also note that below will make use of the KMS key alias `terraform`.

## cfssl Configuration

The documentation for configuration for `cfssl` is, unfortunately, not present.

The best we can do, is to reference the
[Go package documentation](https://godoc.org/github.com/cloudflare/cfssl/config). The included
configuration `config.json` should be sufficient for most purposes.

## CSR Configuration

The documentation for this is sparse. The reference for the
[Go package](https://godoc.org/github.com/cloudflare/cfssl/csr) and this
[page](https://github.com/cloudflare/cfssl/wiki/Creating-a-new-CSR) are all we have at this moment.

## Generate a key for the root CA and create a certificate for the root CA

Create a [CSR JSON](https://github.com/cloudflare/cfssl/wiki/Creating-a-new-CSR). An example is
provided in `root/csr.json`.

For example

```bash
cfssl gencert -config config.json -profile ca -initca root/csr.json | cfssljson -bare root/ca
```

*DO NOT CHECK IN `ca-key.pem` unencrypted!* The CSR does not need to be checked in. The `.gitignore`
set-up should prevent this file from being accidentally checked in.

## Encrypt the CA private key with AWS KMS

You should decide on an Encryption context so that you can use
[Grants](https://docs.aws.amazon.com/kms/latest/developerguide/grants.html) to control access
to the CA Private key. You _must_ remember the context you have set or you will not be able to
decrypt the key in the future.

An example context is in [`root/cli.json`](root/cli.json).

The following example will encrypt the key and store it in binary.

```bash
aws kms encrypt \
    --key-id "alias/terraform" \
    --plaintext fileb://root/ca-key.pem \
    --output text --query CiphertextBlob \
    --cli-input-json file://root/cli.json \
| base64 --decode \
> root/ca.key
```

Verify that the encrypted file can be decrypted successfully and equally to the original key file
(be sure not to print the key):

```bash
aws kms decrypt \
    --ciphertext-blob fileb://root/ca.key \
    --output text \
    --query Plaintext \
    --cli-input-json file://root/cli.json \
| base64 --decode \
| diff root/ca-key.pem - > /dev/null \
|| echo "The keys are different!"
```

If the message `The keys are different!` does not appear, this means that the set-up is working.

You can now safely delete `root/ca-key.pem`.

### Viewing the Certificate

You can use the command below to view details of the certificate.

```bash
openssl x509 -in root/ca.pem -text -noout
```

## Store the encrypted key

You can store the encrypted key in the repository. The files stored are:

- `ca.key`: Encrypted private key for the CA
- `ca.pem`: The self signed CA certificate
- `csr.json`: The CSR used to generated the CA certificate

## Decrypt the private key

```bash
aws kms decrypt \
    --ciphertext-blob fileb://root/ca.key \
    --output text \
    --query Plaintext \
    --cli-input-json file://root/cli.json \
| base64 --decode \
> root/ca-key.pem
```

Don't forget to delete the decrypted key! Simply run:

```bash
rm root/ca-key.pem
```

to do so.

## Renew CA with the same key

```bash
cfssl gencert -renewca -ca root/ca.pem -ca-key root/ca-key.pem
```

## Issue an intermediate CA

You might want to issue an intermediate CA, for example, to be used with Vault.

1. Generate a new key pair and CSR.
1. Decrypt the root CA key as described above.
1. Sign the certificate.
1. Encrypt your private key for storage.

We will look at the provided example `vault`.

```bash
# Generate a new key pair and CSR
cfssl genkey -config config.json -profile ca -initca vault/csr.json | cfssljson -bare vault/ca

# Generate a certificate and sign it with the root CA key
cfssl sign -ca root/ca.pem -ca-key root/ca-key.pem -config config.json -profile ca vault/ca.csr \
    | cfssljson -bare vault/ca
```

You can encrypt the new key with the following command:

```bash
aws kms encrypt \
    --key-id "alias/terraform" \
    --plaintext fileb://vault/ca-key.pem \
    --output text --query CiphertextBlob \
    --cli-input-json file://vault/cli.json \
| base64 --decode \
> vault/ca.key
```

## Issue a new certificate

1. Generate a new key pair and CSR.
1. Decrypt the key of the CA you want to sign the certificate with.
1. Sign the certificate.
1. Encrypt the private key.

For example, if we want to generate a new certificate to serve Vault's API:

```bash
# Generate a new key pair and CSR
cfssl genkey -config config.json -profile peer vault-cert/csr.json | cfssljson -bare vault-cert/cert

# Generate a certificate and sign it with the root CA key
cfssl sign -ca root/ca.pem -ca-key root/ca-key.pem -config config.json -profile peer \
    vault-cert/cert.csr \
    | cfssljson -bare vault/cert
```

You can encrypt the new key with the following command:

```bash
aws kms encrypt \
    --key-id "alias/terraform" \
    --plaintext fileb://vault-cert/cert-key.pem \
    --output text --query CiphertextBlob \
    --cli-input-json file://vault-cert/cli.json \
| base64 --decode \
> vault-cert/cert.key
```

## Resources

[Guide](https://technedigitale.com/archives/639)
