# Vault PKI

This module serves as a bootstrap addon for the Core module. It provisions the
[PKI secrets engine](https://www.vaultproject.io/docs/secrets/pki/index.html) in Vault. This PKI
secrets engine allows you to maintain an internal CA and allows Vault users to request for
certificates.

This module is required for some of the other Vault integration.

## Pre-requisites

You must have Terraformed the [core](../core) module first. In addition, you must have at least
initialised and unsealed the Vault servers.

## Vault Provider

Refer to the [documentation](https://www.terraform.io/docs/providers/vault/index.html) on the
Terraform Vault provider for details on how you can provide a Vault token for this Terraform
operation. In general, you might want to do this with a Root token.

## Core Module Integration

After you have applied this module, a key will be set in Consul's KV store. When you are building
the default Packer templates for Consul, Nomad Servers, Nomad Clients, or Vault, you can optionally
ask the template to install the CA certificate from the provisioned PKI secrets engine. The template
will then reference Consul for the URLs to obtain the CA certificate. See the individual Packer
template documentation for more details.

You might want to rebuild and update all the AMIs for your server so that your CA is installed onto
the AMI. This is necessary if you want to enable TLS for Nomad and Consul.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ca_cn | The CN of the CA certificate | string | `Vault TLS Authority` | no |
| ca_exclude_cn_from_sans | If set, the given common_name will not be included in DNS or Email Subject Alternate Names (as appropriate). Useful if the CN is not a hostname or email address, but is instead some human-readable identifier. | string | `true` | no |
| ca_ip_san | Specifies the requested IP Subject Alternative Names, in a comma-delimited list. | string | `` | no |
| ca_san | Specifies the requested Subject Alternative Names, in a comma-delimited list.   These can be host names or email addresses; they will be parsed into their respective fields. | string | `` | no |
| consul_key_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has         been applied. If you change this, you have to update the         `integration_consul_prefix` variable in the core module as well. | string | `terraform/` | no |
| core_integration | Enable integration with the `core` module by setting some values in Consul so         that the packer templates know this module has been applied. | string | `true` | no |
| country | Specifies the C (Country) values in the subject field of the resulting certificate. This is a comma-separated string or JSON array. | string | `<list>` | no |
| locality | Specifies the L (Locality) values in the subject field of the resulting certificate. This is a comma-separated string or JSON array. | string | `<list>` | no |
| organization | Specifies the O (Organization) values in the subject field of the resulting certificate.  This is a comma-separated string or JSON array. | string | `` | no |
| ou | Specifies the OU (OrganizationalUnit) values in the subject field of the resulting certificate. This is a comma-separated string or JSON array. | string | `` | no |
| pki_max_ttl | Max TTL for the PKI secrets engine in seconds | string | `315360000` | no |
| pki_path | Path to mount the PKI secrets engine | string | `pki` | no |
| pki_ttl | Default TTL for PKI secrets engine in seconds | string | `31536000` | no |
| postal_code | Specifies the Postal Code values in the subject field of the resulting certificate. This is a comma-separated string or JSON array. | string | `<list>` | no |
| province | Specifies the ST (Province) values in the subject field of the resulting certificate. This is a comma-separated string or JSON array. | string | `<list>` | no |
| street_address | Specifies the Street Address values in the subject field of the resulting certificate. This is a comma-separated string or JSON array. | string | `<list>` | no |
| vault_base_url | Base URL where your Vault cluster can be accessed. This is used to configure the CRL and CA   endpoints. Do not include a trailing slash. | string | `<list>` | no |

## Outputs

| Name | Description |
|------|-------------|
| ca_endpoints_der | Endpoints where the CA certificate can be downloaded in DER form |
| ca_endpoints_pem | Endpoints where the CA certificate can be downloaded in PEM form |
| crl_distribution_points | Endpoints to download the CRL |
