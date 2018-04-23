# Nomad ACL

[ACL](https://www.nomadproject.io/guides/acl.html) can be enabled for Nomad so that only users
with the necessary tokens can submit jobs. This module only enables the built-in access controls
provided by the ACL facility in the Open Source version of Nomad. Additional controls provided
by Sentinel in the Enterprise version is not enabled.

This module __does not__ create the necessary Vault and Nomad policies. These policies are very
specific to your use case and you should define them yourselves.

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

Firstly, this requires the Nomad clients and servers to be configured with the
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
    key {
        path = "terraform/nomad-acl/enabled"
        value = "true"
    }
}
```

After this is done, update the Nomad servers _first_ according to the instructions provided
in the Core module. You might get `permission denied` if you try to use the `nomad server members`
command to check if the servers are up.

You can use the [status API](https://www.nomadproject.io/api/status.html) instead which does not
require any ACL.

Secondly, we will need to generate a Nomad Bootstrap token. Use the
[`acl bootstrap`](https://www.nomadproject.io/docs/commands/acl/bootstrap.html) command.

**Important**: Make sure you save the token somewhere safe. If you lose this and all other
management tokens, you will have to
[reset](https://www.nomadproject.io/guides/acl.html#resetting-acl-bootstrap) the bootstrap manually.

After this is done, you can proceed to update the Nomad clients.

## Nomad Provider

You will need to have a Nomad management ACL token to be able to Terraform this. The initial
bootstrap will require the bootstrap token. Afterwards, you can use any management token. Provide
a `secret_id` Nomad ACL token to the provider. Refer to the
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
