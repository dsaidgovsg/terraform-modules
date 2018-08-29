# Nomad Vault Integration

This module is an example on how you can setup integration between Vault and Nomad. Refer to
[this page](https://www.nomadproject.io/docs/vault-integration/index.html) for more information.

This is intended to be used alongside the [core](../core).

## Pre-requisites

You must have Terraformed the [core](../core) module first. In addition, you must have at least
initialised and unsealed the Vault servers.

You **must** also provision this with the [aws-auth](../aws-auth) module. You **must** give the
`nomad_server` token role in `aws-auth` the `nomad_server` policy.

You can use both modules in the same Terraform module to provision to satisfy the requirements.
For example:

```hcl

module "nomad_vault_integration" {
    source = "..."

    # ...
}

module "aws_auth" {
    source = "..."

    # ...

    # Attach policy to allow creation of tokens for Nomad servers
    nomad_server_policies = ["...", "${module.nomad_vault_integration.nomad_server_policy_name}"]
}

```

## Vault Provider

Refer to the [documentation](https://www.terraform.io/docs/providers/vault/index.html) on the
Terraform Vault provider for details on how you can provide a Vault token for this Terraform
operation. In general, you might want to do this with a Root token.

## Consul Provider

Refer to the [documentation](https://www.terraform.io/docs/providers/consul/index.html)
on how to configure the ACL token for the provider if needed.

## Vault Token

Instead of generating a Vault Token by hand while configuring Nomad, we instead choose to configure
Vault to enable the [AWS authentication method](https://www.vaultproject.io/docs/auth/aws.html) so
that Nomad servers instance will be able to retrieve a token on first boot purely by authenticating
with Vault via their Instance Profile.

## What this module does

This module first provisions two policies and
[token roles](https://www.vaultproject.io/api/auth/token/index.html#create-update-token-role)
in Vault.

### Policies

- `nomad_server_policy`: This policy allows the token holder to create a periodic token with the `nomad_cluster_policy` using the `nomad_server` token role.
- `nomad_cluster_policy`: This policy allows Nomad to create child tokens for jobs that require it.

### Roles

- `nomad_server`: This allows the creation of a token that is passed to Nomad for Nomad to create child tokens for use with jobs using the `nomad_cluster` role.
- `nomad_cluster`: This role is used by Nomad servers to create child tokens for use with jobs.

### Tokens

Using a source token obtained from the `aws-auth` module that has the `nomad_server_policy`, we
can create a new `nomad_cluster` token using the `nomad_cluster` role.

The `nomad_cluster` token will then be passed to Nomad servers for Nomad to manage. This token will
be used by Nomad servers to create child tokens for use with jobs.

## Integration with `Core` module

After you have applied this module, a key will be set in Consul's KV store. The default
`user_data` scripts of the Core's Nomad servers and clients will check for the presence of this
key in Consul to configure themselves accordingly. Refer to the Core module's documentation on how
to update your Nomad cluster.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allow_unauthenticated | Specifies if users submitting jobs to the Nomad server should be required to provide         their own Vault token, proving they have access to the policies listed in the job.         This option should be disabled in an untrusted environment. | string | `false` | no |
| consul_key_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has         been applied. If you change this, you have to update the         `integration_consul_prefix` variable in the core module as well. | string | `terraform/` | no |
| core_integration | Enable integration with the `core` module by setting some values in Consul so         that the user_data scripts in core know that this module has been applied | string | `true` | no |
| nomad_cluster_disallowed_policies | Additional policies that tokens created by Nomad servers are not allowed to have | string | `<list>` | no |
| nomad_cluster_policy | Name of the policy for tokens passed to Nomad servers | string | `nomad-cluster` | no |
| nomad_cluster_role | Name for the Token role that is used by the Nomad server to create tokens | string | `nomad-cluster` | no |
| nomad_cluster_suffix | Suffix to create tokens with. See https://www.vaultproject.io/api/auth/token/index.html#path_suffix for more information | string | `nomad-cluster` | no |
| nomad_server_policy | Name of the policy to allow for the creation of the token to pass to Nomad servers | string | `nomad-server` | no |
| nomad_server_role | Name of the token role that is used to create Tokens to pass to Nomad | string | `nomad-server` | no |

## Outputs

| Name | Description |
|------|-------------|
| nomad_cluster_policy | Policy that allows Nomad servers to create child tokens for jobs |
| nomad_cluster_policy_name | Name of policy that allows Nomad servers to create child tokens for jobs |
| nomad_cluster_token_role | Token role configuration to allow Nomad servers to create child tokens |
| nomad_server_policy | Policy that allows the creation of a token to pass to the Nomad cluster servers |
| nomad_server_policy_name | Name of policy that allows the creation of a token to pass to the Nomad cluster servers |
| nomad_server_token_role | Token role configuration to create a token with the nomad_cluster policy |
