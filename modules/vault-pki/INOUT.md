## Providers

| Name | Version |
|------|---------|
| consul | n/a |
| template | n/a |
| vault | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| ca\_cn | The CN of the CA certificate | `string` | `"Vault TLS Authority"` | no |
| ca\_exclude\_cn\_from\_sans | If set, the given common\_name will not be included in DNS or Email Subject Alternate Names<br>(as appropriate).<br>Useful if the CN is not a hostname or email address, but is instead some human-readable identifier. | `bool` | `true` | no |
| ca\_ip\_san | Specifies the requested IP Subject Alternative Names, in a comma-delimited list. | `string` | `""` | no |
| ca\_san | Specifies the requested Subject Alternative Names, in a comma-delimited list.<br>  These can be host names or email addresses; they will be parsed into their respective fields. | `string` | `""` | no |
| consul\_key\_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has<br>        been applied. If you change this, you have to update the<br>        `integration_consul_prefix` variable in the core module as well. | `string` | `"terraform/"` | no |
| core\_integration | Enable integration with the `core` module by setting some values in Consul so<br>        that the packer templates know this module has been applied. | `bool` | `true` | no |
| country | Specifies the C (Country) values in the subject field of the resulting certificate.<br>This is a comma-separated string or JSON array. | `list` | `[]` | no |
| locality | Specifies the L (Locality) values in the subject field of the resulting certificate.<br>This is a comma-separated string or JSON array. | `list` | `[]` | no |
| organization | Specifies the O (Organization) values in the subject field of the resulting certificate.<br> This is a comma-separated string or JSON array. | `string` | `""` | no |
| ou | Specifies the OU (OrganizationalUnit) values in the subject field of the resulting certificate.<br>This is a comma-separated string or JSON array. | `string` | `""` | no |
| pki\_max\_ttl | Max TTL for the PKI secrets engine in seconds | `number` | `315360000` | no |
| pki\_path | Path to mount the PKI secrets engine | `string` | `"pki"` | no |
| pki\_ttl | Default TTL for PKI secrets engine in seconds | `number` | `31536000` | no |
| postal\_code | Specifies the Postal Code values in the subject field of the resulting certificate.<br>This is a comma-separated string or JSON array. | `list` | `[]` | no |
| province | Specifies the ST (Province) values in the subject field of the resulting certificate.<br>This is a comma-separated string or JSON array. | `list` | `[]` | no |
| street\_address | Specifies the Street Address values in the subject field of the resulting certificate.<br>This is a comma-separated string or JSON array. | `list` | `[]` | no |
| vault\_base\_url | Base URL where your Vault cluster can be accessed. This is used to configure the CRL and CA<br>  endpoints. Do not include a trailing slash. | `list` | <pre>[<br>  "https://vault.service.consul:8200"<br>]<br></pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| ca\_endpoints\_der | Endpoints where the CA certificate can be downloaded in DER form |
| ca\_endpoints\_pem | Endpoints where the CA certificate can be downloaded in PEM form |
| crl\_distribution\_points | Endpoints to download the CRL |

