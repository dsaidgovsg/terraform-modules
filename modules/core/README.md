# Deploy Nomad, Vault and Consul clusters using Terraform

This is based on the
[example](https://github.com/hashicorp/terraform-aws-nomad/tree/master/examples/nomad-consul-separate-cluster)
by Hashicorp.

The vault deployment is based off this
[example](https://github.com/hashicorp/terraform-aws-vault/tree/master/examples/vault-cluster-private).

## Basic Concepts

This Terraform module allows you to bootstrap an initial cluster of Consul servers, Vault servers,
Nomad servers, and Nomad clients.

After the initial bootstrap, you will need to perform additional configuration for production
hardening. In particular, you will have to initialise Vault and configure Vault before you can use
it for anything.

You can use the other companion Terraform modules in this repository to perform some of the
configuration. They are documented briefly below, and in more detail in their own directories.

## Requirements

- AWS account with an access key and secret for programmatic access
- [Ansible](https://github.com/ansible/ansible/releases)
- [AWS CLI](https://aws.amazon.com/cli/)
- [terraform](https://www.terraform.io/)
- [nomad](https://www.nomadproject.io/)
- [consul](https://www.consul.io/)
- [vault](https://www.vaultproject.io/)

You should consider using
[named profiles](https://docs.aws.amazon.com/cli/latest/userguide/cli-multiple-profiles.html) to
store your AWS credentials.

## Prerequisites

### Terraform remote state

Terraform is configured to store its state on a S3 bucket. It will also use a DynamoDB table to
perform locking.

You should setup a S3 bucket to store the state, and then create a DynamoDB table with `LockID`
as its string primary key.

Then, configure it a file such as `backend-config.tfvars`. See
[this page](https://www.terraform.io/docs/backends/types/s3.html) for more information.

### AWS Pre-requisites

- Have a domain either registered with AWS Route 53 or other registrar.
- Create an AWS Hosted zone for the domain or subdomain. If the domain is registered with another registrar, it must have its name servers set to AWS.
- Use AWS Certficate Manager to request certificates for the domain and its wildcard subdomains. For example, you need to request a certificate that contains the names `nomad.some.domain` AND `*.nomad.some.domain`.

### Certificates

You will need to generate the following certificates:

- A Root CA
- Vault Certificate

<!-- In addition, if you want to enable some post bootstrap integration, you will need the following
certificates or CAs:

- Vault Intermediate CA (Optional)
- Consul Certificate -->

Refer to instructions [here](ca/README.md).

### Preparing Secrets

#### Consul Gossip Encryption

If you would like to enable
[gossip encryption](https://www.consul.io/docs/agent/encryption.html#gossip-encryption) on Consul,
you will have to:

- Generate a new encryption key with `consul keygen`.
- Refer to [`packer/common/consul_gossip_base.json`](packer/common/consul_gossip_base.json) and fill in the values accordingly. Take care _not_ to check in the file to your source control unencrypted.

You should then use this `consul_gossip_base.json` variable file as a common file to be included
as part of _all_ your Packer AMI building.

## Building AMIs

We first need to use [packer](https://www.packer.io/) to build several AMIs. You will also need to
have Ansible 2.5 installed.

The list below will link to example packer scripts that we have provided. If you have additional
requirements, you are encouraged to extend from these examples.

- [Consul servers](package/consul)
- [Nomad servers (with Consul agent)](packer/nomad_servers)
- [Nomad clients (with Consul agent)](packer/nomad_clients)
- [Vault (with Consul agent)](packer/vault)

Read [this](https://www.packer.io/docs/builders/amazon.html#specifying-amazon-credentials) on how
to specify AWS credentials.

Refer to each of the directories for instruction.

Take note of the AMI IDs returned from this.

## Defining Variables

You should refer to `variables.tf` and then create your own
[variable file](https://www.terraform.io/intro/getting-started/variables.html#from-a-file).

Most of the variables should be pretty straight forward and are documented inline with their
description. Some of the more complicated variables are described below.

### `vault_tls_key_policy_arn`

The [Vault packer template](packer/vault) and this module expects Vault to be deployed with TLS
certificate and the key. The key is expected to be encrypted using a Key Management Service (KMS)
Customer Managed Key (CMK).

In order for the Vault EC2 instances to be able to decrypt the keys on first run, the instances will
need to be provided with the necessary IAM policy.

You will have to define the appropriate IAM policy, and then provide the ARN of the IAM policy
using the `vault_tls_key_policy_arn` variable.

Before you can define an IAM policy, you have to define the appropriate key policy for your CMK
so that the keys policies can be managed by IAM. Refer to
[this document](https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html) for more
information.

After that is done, you can following the example below to define the appropriate policy.

```hcl
# Use this to retrieve the ARN of a KMS CMK with the alias `terraform`
data "aws_kms_alias" "terraform" {
    name = "alias/terraform"
}

# Define the policy using this data source. If you used the example `cli.json`, this should suffice
# See https://docs.aws.amazon.com/kms/latest/developerguide/iam-policies.html
data "aws_iam_policy_document" "vault_decrypt" {
    policy_id = "VaultTlsDecrypt"

    statement {
        effect = "Allow"
        actions = [
            "kms:Decrypt"
        ]

        resources = [
            "${data.aws_kms_alias.terraform.target_key_arn}"
        ],

        condition {
            test = "StringEquals"
            variable = "kms:EncryptionContext:type"
            values = ["key"]
        }

        condition {
            test = "StringEquals"
            variable = "kms:EncryptionContext:usage"
            values = ["encryption"]
        }
    }
}

resource "aws_iam_policy" "vault_decrypt" {
    name = "VaultTlsDecrypt"
    description = "Policy to allow Vault to use the KMS terraform key to decrypt key encrypting keys."
    policy = "${data.aws_iam_policy_document.vault_decrypt.json}"
}

module "core" {
    source = "..."

    vault_tls_key_policy_arn = "${aws_iam_policy.vault_decrypt.arn}"
}

```

## Terraform

### Initialize Terraform

Terraform will need to be initialized with the appropriate backend settings:

```bash
terraform init --backend-config backend-config.tfvars
```

### Running Terraform

Assuming that you have a variable file named `vars.tfvars`, you can simply run `terraform` with:

```bash
# Preview the plan
terraform plan --var-file vars.tfvars

# Execute the plan
terraform apply --var-file vars.tfvars

```

## Consul, Docker and DNS Gotchas

See [this post](https://medium.com/zendesk-engineering/making-docker-and-consul-get-along-5fceda1d52b9)
for a solution.

## Post Terraforming Tasks

As indicated above, the initial Terraform apply will bootstrap the cluster in a usable but
unhardened manner. You will need to perform some tasks to harden it further.

### Vault Initialisation and Configuration

After you have applied the Terraform plan, we need to perform some manual steps in order to set up
Vault.

The helper script `vault-helper.sh` will have some instructions on what you need to do to initialise
and unseal the servers

You can use our [utility Ansible playbooks](https://github.com/GovTechSG/vault-utils) to perform
the tasks.

To generate an inventory for the playbooks, you can run

```bash
./vault-helper.sh -i > inventory
```

### Vault Integration with Nomad

Nomad can be [integrated](https://www.nomadproject.io/docs/vault-integration/index.html) with Vault
so that jobs can transparently retrieve tokens from Vault.

After you have initialised and unsealed Vault, you can use the
[`nomad-vault-integration`](../nomad-vault-integration) module to Terraform the required policies
and settings for Vault.

Make sure you have properly configured Vault with the appropriate
[authentication methods](https://www.vaultproject.io/docs/auth/index.html) so that your users can
authenticate with Vault to get the necessary tokens and credentials.

The default `user_data` scripts for Nomad servers and clients will automatically detect that the
policies have been setup and will configure themselves correctly. To update your cluster to use
the new Vault integration, simply follow the section below to update the Nomad servers first and
then the clients.

### Nomad ACL

[ACL](https://www.nomadproject.io/guides/acl.html) can be enabled for Nomad so that only users
with the necessary tokens can submit jobs. This module only enables the built-in access controls
provided by the ACL facility in the Open Source version of Nomad. Additional controls provided
by Sentinel in the Enterprise version is not enabled.

After you have initialised and unsealed Vault, you can use the [`nomad-acl`](../nomad-acl) module to
Terraform the required policies and settings for Vault and Nomad.

Make sure you have properly configured Vault with the appropriate
[authentication methods](https://www.vaultproject.io/docs/auth/index.html) so that your users can
authenticate with Vault to get the necessary tokens and credentials.

The default `user_data` scripts for Nomad servers and clients will automatically detect that the
policies have been setup and will configure themselves correctly. To update your cluster to use
the new Nomad ACL, simply follow the section below to update the Nomad servers first and
then the clients.

### SSH access via Vault

We can use Vault's
[SSH secrets engine](https://www.vaultproject.io/docs/secrets/ssh/signed-ssh-certificates.html) to
generate signed certificates to access your machines via SSH.

See the [`vault-ssh`](../vault-ssh) module for more information.

### Upgrading and updating

In general, to upgrade or update the servers, you will have to update the packer template file,
build a new AMI, then update the terraform variables with the new AMI ID. Then, you can run
`terraform apply` to update the launch configuration.

Then, you will need to terminate the various instances for Auto Scaling Group to start
new instances with the updated launch configurations. You should do this ONE BY ONE.

#### Upgrading Consul

**Important**: It is important that you only terminate Consul instances one by one. Make sure the
new servers are healthy and have joined the cluster before continuing. If you lose more than a
quorum of servers, you might have data loss and have to perform
[outage recovery](https://www.consul.io/docs/guides/outage.html).

1. Build your new AMI, and Terraform apply the new AMI.
1. Terminate the instance that you would like to remove.
1. The Consul server will gracefully exit, and cause the node to become unhealthy, and AWS will
   automatically start a new instance.
1. Make sure the new instance started by AWS is healthy before continuing. For example, use
   `consul operator raft list-peers`.

You can use this AWS CLI command to terminate the instance:

```bash
aws autoscaling \
    terminate-instance-in-auto-scaling-group \
    --no-should-decrement-desired-capacity \
    --instance-id "xxx"
```

Replace `xxx` with the instance ID.

#### Upgrading Nomad Servers

**Important**: It is important that you only terminate Nomad server instances one by one.
Make sure the new servers are healthy and have joined the cluster before continuing.
If you lose more than a quorum of servers, you might have data loss and have to perform
[outage recovery](https://www.nomadproject.io/guides/outage.html).

1. Build your new AMI, and Terraform apply the new AMI.
1. Terminate the instance that you would like to remove.
1. The nomad server will gracefully exit, and cause the node to become unhealthy, and AWS will
   automatically start a new instance.
1. Make sure the new instance started by AWS is healthy before continuing. For example, use
   `nomad server members` to check whether the new instances created have joined the cluster.

You can use this AWS CLI command:

```bash
aws autoscaling \
    terminate-instance-in-auto-scaling-group \
    --no-should-decrement-desired-capacity \
    --instance-id "xxx"
```

Replace `xxx` with the instance ID.

#### Upgrading Nomad Clients

**Important**: These steps are recommended to minimise the outage your services might experience. In
particular, if your service only has one instance of it running, you will definitely encounter
outage. Ensure that your services have at least two instances running.

1. Build your new AMI, and Terraform apply the new AMI.
2. Take note of the old instances ID that you are going to retire. You can get a list of the instance IDs with the command:

```bash
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-name ASGName \
    | jq --raw-output '.AutoScalingGroups[0].Instances[].InstanceId' \
    | tee instance-ids.txt
```

3. Using Terraform or the AWS console, set the `desired` capacity of your auto-scaling group to twice the current desired value. Make sure the `maximum` is set to a high enough value so that you set the appropriate `desired` value. This spins up new clients that will take over the allocations from the instances you are retiring. Alternatively, you can use the [AWS CLI](https://docs.aws.amazon.com/cli/latest/reference/autoscaling/update-auto-scaling-group.html) too:

```bash
aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name ASGName \
    --max-size xxx \
    --desired-capacity xxx
```

Wait for the new nodes to be ready before you continue.

4. Find the Nomad node IDs for each instance. Assuming you have saved the instance IDs to `instance-ids.txt` and that you have kept the default configuration where the node name is the instance ID:

```bash
nomad node status -json > nodes.json
echo -n "" > node-ids.txt
while read p; do
    jq --raw-output ".[] | select (.Name == \"${p}\") | .ID" nodes.json  >> node-ids.txt
done < instance-ids.txt
```

5. Set the instances you are going to retire as
["ineligible"](https://www.nomadproject.io/docs/commands/node/eligibility.html) in Nomad. For example, assuming you have saved the node IDs to `node-ids.txt`:

```bash
while read p; do
  nomad node eligibility -disable "${p}"
done < node-ids.txt
```

6. The following has to be done **one instance at a time**. Detach the instance from the ASG and wait for the ELB connections to drain. **Make sure you wait for the connections to completely drain first before continuing.** Then, [drain](https://www.nomadproject.io/docs/commands/node/drain.html) the clients.

<!-- FIXME: We should not be doing all these on all the instances at one go. Fix this section by
writing and testing a new script. Previous version left for posterity for now.-->

<!-- For example, assuming you have saved the instance IDs to `instance-ids.txt` and node IDs to
`node-ids.txt:

```bash
aws autoscaling detach-instances \
    --auto-scaling-group-name ASGName \
    --instance-ids $(cat instance-ids.txt | tr '\n' ' ') \
    --should-decrement-desired-capacity
```

You can monitor the connection draining in the AWS Console or you can use this command repeatedly
until all the instances are no longer associated with the ASG and the count returns zero:

```bash
COUNT="999";
while [[ "${COUNT}" != "0" ]]; do \
    COUNT=$(aws autoscaling describe-auto-scaling-instances \
    --instance-ids $(cat instance-ids.txt | tr '\n' ' ') \
    | jq '.AutoScalingInstances | length'); \
    echo "Still ${COUNT} instances. Retrying in 5 seconds"; \
    sleep 5; \
done; \
echo "Done"
```

```bash
while read p; do
  nomad node drain -enable "${p}"
done < node-ids.txt
``` -->

7. After the allocations are drained, terminate the instances.  For example, assuming you have saved the instance IDs to `instance-ids.txt`:

```bash
aws ec2 terminate-instances \
    --instance-ids $(cat instance-ids.txt | tr '\n' ' ')
```

#### Upgrading Vault

**Important**: It is important that you update the instances one by one. Make sure the new instance
is healthy, has joined the cluster and is **unsealed** first before continuing.

1. Terminate the instance and AWS will automatically start a new instance.
1. **Unseal the new instance.** If you do not do so, new instances will eventually be unable to configure themselves properly. This is especially so if you have performed any post bootstrap configuration.

You can seal the server by SSH'ing into the server and running `vault operator seal` with the
required token. You can optionally use our
[utility Ansible playbooks](https://github.com/GovTechSG/vault-utils) to do so.

You can terminate instances by using this AWS CLI command:

```bash
aws autoscaling \
    terminate-instance-in-auto-scaling-group \
    --no-should-decrement-desired-capacity \
    --instance-id "xxx"
```

Replace `xxx` with the instance ID.
