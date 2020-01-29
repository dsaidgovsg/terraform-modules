# AWS Authentication

This module configures Vault to accept authentication via
[AWS](https://www.vaultproject.io/docs/auth/aws.html). Specifically, it configures Vault to accept
authentication via EC2 instance metadata.

This module will create roles for each type of servers that is provisioned by the `core` module.

- Consul Servers
- Nomad Servers
- Nomad Clients
- Vault Servers

## Integration with other modules

This module is required for use with many other Vault integration modules. Refer to each
module's documentation on how they can be used together.

In particular, when provisioned, the `user_data` scripts of the Core modules will attempt to
retrieve a Vault token for use with [consul-template](https://github.com/hashicorp/consul-template)
and consul-template will attempt to renew the token.

## Pre-requisites

You must have Terraformed the [core](../core) module first. In addition, you must have at least
initialised and unsealed the Vault servers.

## Vault Provider

You must be using Vault provider version `~> 1.1.4` due to the breaking changes in many of the field
types. See the Vault provider
[CHANGELOG](https://github.com/terraform-providers/terraform-provider-vault/blob/master/CHANGELOG.md#114-september-20-2018)
for more details.

Refer to the [documentation](https://www.terraform.io/docs/providers/vault/index.html) on the
Terraform Vault provider for details on how you can provide a Vault token for this Terraform
operation. In general, you might want to do this with a Root token.

## Authenticating additional server types

*Before continuing, it is recommended that you read through the documentation on the [AWS authentication ](https://www.vaultproject.io/docs/auth/aws.html) provided with Vault. There are many configuration options available in addition to what is mentioned here.*

You can add additional server types to authentication with the AWS authentication method that is
mounted by this module. In particular, the
[EC2 authentication method](https://www.vaultproject.io/docs/auth/aws.html#ec2-auth-method) would be
more useful since we are authenticating EC2 instances. You might want to do so, for example, when
you want to add a separate cluster of Nomad Clients using the [../nomad-clients](`nomad-clients`)
module and you want to have different sets of Vault policies for this additional cluster.

Additional server types can be added as authentication candidates by adding
["roles"](https://www.vaultproject.io/api/auth/aws/index.html#create-role). This can be accomplished
with Terraform using the
[`vault_aws_auth_backend_role`](https://www.terraform.io/docs/providers/vault/r/aws_auth_backend_role.html)
resource. You might want to consider giving the role tokens a `period` instead of a `max_ttl`
because your instances might be long running.

You can read about how EC2 instances can be authenticated with Vault
[here](https://www.vaultproject.io/docs/auth/aws.html#ec2-auth-method).

### Integrating with Consul Template

The [`install-consul-template`](../core/packer/roles/install-consul-template) Ansible role that is
included by default in the Packer templates for the AMIs in the core module can help automate
the process of acquiring a token with Vault and the continued renewal of the token. During the
initial startup of an instance, a bootstrap script is invoked to acquire the Vault Token and then
have [systemd](https://wiki.debian.org/systemd) run and maintain the Consul Template process.

In order to use the bootstrap script and role in your AMIs, you must make sure the following
requirements are met:

- Provision the AMI using the [`install-consul-template`](../core/packer/roles/install-consul-template) Ansible role.
- Run the `run-consul-template` script to bootstrap the instance.
- Define the key under the path `${prefix}aws-auth/roles/${server_type}` in Consul KV store with the name of the role for the server type (see below).

Each role in the AWS authentication mount point is associated with a "server type". During the
token acquisition, the Consul Template bootstrap script will lookup the Consul KV store under the
path `${prefix}aws-auth/roles/${server_type}` for the corresponding role in Vault, where `prefix`
is the Core integration prefix and defaults to `terraform/`.

Then, it will use the instance metadata document of the instance to attempt to authenticate with
Vault using the role it has found. The script will then configure Consul Template and then
setup systemd to start Consul Template. Consul Template will now take care of managing the
lifecycle of the Vault token.

#### Example with `nomad-clients`

In this example, we have setup an additional cluster of Nomad clients. We will setup authentication
with Vault using a role that restricts by the IAM role of this new Nomad client cluster. If you
use the default `user_data` script that comes with the module, Consul Template will be setup to
run automatically.

```hcl
locals {
  server_type = "additional_nomad_clients"
}

module "additional_nomad_clients" {
  # ...

  integration_service_type = "${local.server_type}"
}

module "aws_auth" {
  # ...
}

# Define Role in AWS authentication
resource "vault_aws_auth_backend_role" "additional_nomad_clients" {
  backend            = "${module.aws_auth.path}"
  role               = "${local.server_type}"
  auth_type          = "ec2"
  bound_iam_role_arn = "${module.additional_nomad_clients.iam_role_arn_nomad_clients}"
  policies           = ["..."]
  period             = "120" # in minutes
}

# Define value in Consul KV store to enable Consul Template script to work
resource "consul_keys" "additional_nomad_clients" {
  key {
    path   = "${var.consul_key_prefix}aws-auth/roles/additional_nomad_clients"
    value  = ""${local.server_type}""
    delete = true
  }
}
```

## Different AWS Accounts

Vault support authenticating servers that are on a different AWS account (the `other` account)
from the one that Vault is running on (the `current` account). However, you would need to do the
following:

- Create an IAM role on the `other` account with the appropriate policy to give the `current` account access
- Attach IAM Policy to the IAM role in the `other` account
- Give Vault's IAM role the permission to assume the role defined on the `other` account
- Configure Vault to use the appropriate STS role

If you are unfamiliar with Roles and assuming roles, refer to the
[documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) from AWS.

### IAM role on `other` account

Using Terraform, the AWS Console, or the AWS CLI, you should first
[create](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user.html) in the
`other` account. You should define the "assume role policy" to dictate which accounts are allowed
to assume the role. For example, the following policy would work:

```json
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": { "AWS": "arn:aws:iam::123456789012:root" },
    "Action": "sts:AssumeRole",
    "Condition": { "Bool": { "aws:MultiFactorAuthPresent": "true" } }
  }
}
```

`123456789012` is the
[account ID](https://docs.aws.amazon.com/IAM/latest/UserGuide/console_account-alias.html)
of the `current` account.

You can achieve something similar using the
[`aws_iam_role`](https://www.terraform.io/docs/providers/aws/r/iam_role.html) resource in Terraform.

### IAM policy for role in `other` account

After we have created the role above, we still need to give the role some permissions. In our
scenario, we will have to give the role the
[recommended IAM policy](https://www.vaultproject.io/docs/auth/aws.html#recommended-vault-iam-policy)
so that Vault can verify the instances.

We do this by using the AWS Console, CLI or Terraform to create a new policy and then
[attach](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user.html) the policy
to the IAM role.

In Terraform, you can use the
[`aws_iam_policy`](https://www.terraform.io/docs/providers/aws/r/iam_policy.html) resource to create
the policy, and then attach it to the IAM role using the
[`aws_iam_role_policy_attachment`](https://www.terraform.io/docs/providers/aws/r/iam_role_policy_attachment.html)
resource.

### Vault's IAM Role permission to assume the role

We will next need to give the Vault EC2 instance the permission to assume the role on the `other`
account via its IAM role. Vault has the recommended policy
[documented](https://www.vaultproject.io/docs/auth/aws.html#recommended-vault-iam-policy).

### Configure Vault to use the STS Role

Finally, we will have to configure Vault to assume the IAM Role created in the `other` account when
it encounters instances that belong to the `other` account. You can refer to Vault's
[API documentation](https://www.vaultproject.io/api/auth/aws/index.html#create-sts-role) on how to
do so.

### Terraform Example

```hcl
locals {
  current_vault_iam_role_arn = "..."
  aws_auth_path = "aws"
}


# Current AWS provider
provider "aws" {
  # ...
}

# Other AWS provider
provider "aws" {
  alias = "other"
  # ...
}

# Current AWS account ID
data "aws_caller_identity" "current" {}

# Other AWS account ID
data "aws_caller_identity" "other" {
  provider = "aws.other"
}

# IAM Role in `other` account
resource "aws_iam_role" "other_vault" {
  provider = "aws.other"

  name = "vault"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": { "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
    "Action": "sts:AssumeRole"
  }
}
EOF
}

######################################################
# Policy in "other" for Vault to verify instances
######################################################
data "aws_iam_policy_document" "vault_aws_auth" {
  provider = "aws.other"

  policy_id = "VaultSTS"

  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "iam:GetInstanceProfile",
      "iam:GetUser",
      "iam:GetRole",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "vault_aws_auth" {
  provider = "aws.other"

  name        = "VaultSTS"
  description = "Policy to allow Vault instances to authenticate entities with AWS IAM. See https://www.vaultproject.io/docs/auth/aws.html"
  policy      = "${data.aws_iam_policy_document.vault_aws_auth.json}"
}

resource "aws_iam_role_policy_attachment" "vault_aws_auth" {
  role       = "${aws_iam_role.other_vault.name}"
  policy_arn = "${aws_iam_policy.vault_aws_auth.arn}"
}

######################################################
# Policy to allow "current" Vault instance to assume Role
######################################################
data "aws_iam_policy_document" "vault_aws_auth_other" {
  policy_id = "VaultSTSOther"

  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "${aws_iam_role.other_vault.arn}",
    ]
  }
}

resource "aws_iam_policy" "vault_aws_auth_other" {
  name        = "VaultSTSOther"
  policy      = "${data.aws_iam_policy_document.vault_aws_auth_other.json}"
}

resource "aws_iam_role_policy_attachment" "vault_aws_auth_other" {
  role       = "${local.current_vault_iam_role_arn}"
  policy_arn = "${aws_iam_policy.vault_aws_auth_other.arn}"
}

######################################################
# Hack to configure Vault to assume IAM role
######################################################
resource "vault_generic_secret" "vault_iam_role" {
  path = "auth/${local.aws_auth_path}/config/sts/${data.aws_caller_identity.other.account_id}"

  data_json = <<EOF
{
  "sts_role": "${aws_iam_role.other_vault.arn}"
}
EOF
}
```

## Inputs and Outputs

Refer to [INOUT.md](INOUT.md)
