# Self-signed Certificate Authority

This directory contains instruction on how to setup a CA to issues certificate for Vault, Consul and
Nomad to perform TLS communication, and finally to import an intermediate CA into Vault to issue
cerficiates for Nomad and other services.

1. [Create a new master key in AWS KMS](https://docs.aws.amazon.com/kms/latest/developerguide/create-keys.html)
1. Generate a key for the CA and create a cerficiate for the CA.
1. Encrypt the key with KMS.
1. (Optional) set up [Grants](https://docs.aws.amazon.com/kms/latest/developerguide/grants.html) for the KMS CMK.
1. Store the encrpyted key.
1. Renew CA with the same key.

The guide will make use of [`cfssl`](https://github.com/cloudflare/cfssl). You can run this in a
Docker container to simplify operations.

```bash
docker run \
    --rm \
    -it \
    --entrypoint "" \
    -v `pwd`:/data \
    --workdir /data \
    --userns host \
    cfssl/cfssl:1.2.0 \
    bash
```

The examples below will make use of the KMS key alias `terraform`.

## Generate a key for the CA and create a cerficiate for the CA

Create a [CSR JSON](https://github.com/cloudflare/cfssl/wiki/Creating-a-new-CSR). An example is
provided in `csr.json`.

For example

```bash
cfssl gencert -initca csr.json | cfssljson -bare ca
```

*DO NOT CHECK IN `ca-key.pem` unencrypted!* The CSR does not need to be checked in.

You might need to `chown` the files so that you can read it.

## Encrypt the CA private key with AWS KMS

You should decide on an Encryption context so that you can use
[Grants](https://docs.aws.amazon.com/kms/latest/developerguide/grants.html) to control access
to the CA Private key. You _must_ remember the context you have set or you will not be able to
decrypt the key in the future.

An example context is in `cli.json`.

The following example will encrypt the key and store it in binary.

```bash
aws kms encrypt \
    --key-id "alias/terraform" \
    --plaintext fileb://ca-key.pem \
    --output text --query CiphertextBlob \
    --cli-input-json file://cli.json \
| base64 --decode \
> ca.key
```

Verify that the encrypted file can be decrypted successfully and equally to the original key file
(be sure not to print the key):

```bash
aws kms decrypt \
    --ciphertext-blob fileb://ca.key \
    --output text \
    --query Plaintext \
    --cli-input-json file://cli.json \
| base64 --decode \
| diff ca-key.pem - > /dev/null \
|| echo "The keys are different!"
```

You can now safely delete `ca-key.pem`.

## Store the encrypted key

You can store the encrypted key in the repository. The files stored are:

- `ca.key`: Private key for the CA
- `ca.pem`: The self signed CA cerfificate
- `csr.json`: The CSR used to generated the CA certificate

## Decrypt the private key

```bash
aws kms decrypt \
    --ciphertext-blob fileb://ca.key \
    --output text \
    --query Plaintext \
    --cli-input-json file://cli.json \
| base64 --decode \
> ca-key.pem
 ```

Don't forget to delete the decrypted key!

## Renew CA with the same key

```bash
cfssl gencert -renewca -ca ca.pem -ca-key ca-key.pem
```

## Issue a new certificate

## Issue an intermediate CA

## Resources

[Guide](https://technedigitale.com/archives/639)
