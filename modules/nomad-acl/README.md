# Nomad ACL

[ACL](https://www.nomadproject.io/guides/acl.html) can be enabled for Nomad so that only users
with the necessary tokens can submit jobs. This module only enables to built in access controls
provided by the ACL facility in the Open Source version of Nomad. Additional controls provided
by Sentinel in the Enterprise version is not enabled.

## Integration with `Core` module

This module is integrated with the `core` module to enable you to use both in conjunction
seamlessly.

## Pre-requisites

You must have Terraformed the [core](../core) module first. In addition, you must have at least
initialised and unsealed the Vault servers.

Make sure you have properly configured Vault with the appropriate
[authentication methods](https://www.vaultproject.io/docs/auth/index.html) so that your users can
authenticate with Vault to get the necessary tokens and credentials.

### Bootstrapping Nomad ACL

We have to manually [bootstrap](https://www.nomadproject.io/guides/acl.html#bootstrapping-acls) ACLs
on the Nomad servers first.

Firstly, this requires that the Nomad servers and servers are configured with the
[`acl` stanza](https://www.nomadproject.io/docs/agent/configuration/acl.html#enabled).

This can be automated with the Core module. Assuming that you have not modified the
`consul_prefix` variable in this module or the `nomad_acl_consul_prefix` variable in the core
module, we just need to put a value of `true` at the path `terraform/nomad-acl/enabled`.

For example, with the command line, we can do:

```bash
consul kv put \
    -http-addr https://consul.example.com \
    terraform/nomad-acl/enabled yes

# Read it back to check
consul kv get \
    -http-addr https://consul.example.com \
    terraform/nomad-acl/enabled
```

Alternatively, you can use Terraform too:

```hcl
resource "consul_keys" "bootstrap" {
    key {p
        path = " terraform/nomad-acl/enabled"
        value = "true"
    }
}
```

After this is done, update the Nomad servers _first_ according to the instructions provided
in the Core module.

## Nomad Provider

You will need to provide a `secret_id` Nomad ACL token to the provider. Refer to the
[documentation](https://www.terraform.io/docs/providers/nomad/index.html) for more information.

In general, you should provide this via the `NOMAD_TOKEN` environment variable.

For example, if you have saved the token in `nomad-acl`, you can simply do

```bash
NOMAD_PROVIDER=$(cat nomad-acl) terraform plan
```

## Vault Provider

Refer to the [documentation](https://www.terraform.io/docs/providers/vault/index.html) on the
Terraform Vault provider for details on how you can provide a Vault token for this Terraform
operation. In general, you might want to do this with a Root token.
