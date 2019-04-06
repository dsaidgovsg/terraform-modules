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
- [Ansible >= 2.6](https://github.com/ansible/ansible/releases)
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

- Create a VPC with the necessary subnets (public, private, database etc.) to deploy this to. For example, you can try [this module](https://github.com/terraform-aws-modules/terraform-aws-vpc).
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

<!-- #### Consul Gossip Encryption

If you would like to enable
[gossip encryption](https://www.consul.io/docs/agent/encryption.html#gossip-encryption) on Consul,
you will have to:

- Generate a new encryption key with `consul keygen`.
- Refer to [`packer/common/consul_gossip_base.json`](packer/common/consul_gossip_base.json) and fill in the values accordingly. Take care _not_ to check in the file to your source control unencrypted.

You should then use this `consul_gossip_base.json` variable file as a common file to be included
as part of _all_ your Packer AMI building. -->

## Building AMIs

We first need to use [packer](https://www.packer.io/) to build several AMIs. You will also need to
have Ansible 2.6 installed.

The list below will link to example packer scripts that we have provided. If you have additional
requirements, you are encouraged to extend from these examples.

- [Consul servers](packer/consul)
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

### Consul Gossip Traffic

Due to a [limitation](https://github.com/GovTechSG/terraform-modules/issues/152) in how Terraform
deals with `count`, we are unable to automatically provision the security group rules for
Nomad (both servers and clients) and Vault instances to retrieve
[Consul Serf Gossip](https://www.consul.io/docs/internals/gossip.html) traffic. The instances can
send _out_ Serf gossip traffic to Consul servers and other peers, but they are unable
to receive any.

It is recommended that you provision the rules for Nomad and Vault instances using this
[Terraform module](https://github.com/hashicorp/terraform-aws-consul/tree/master/modules/consul-client-security-group-rules).

This allows better scaling as the number of nodes in the Consul cluster increases.

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

#### Vault Auto-unseal

Vault 1.0 and above now supports
[auto unseal](https://www.vaultproject.io/docs/concepts/seal.html#auto-unseal) and this module
supports its use.

In general, the steps for initialisation are the same. The only difference is that any operation
(such as upgrading the servers) that requires the restarting of Vault will no longer require manual
unsealing. The unseal keys are then only used for operations like recovery or generating root
tokens, for example.

There are additional steps to perform when configuring for auto-unseal that is not automated for
you by this module:

- Provisioning a KMS Customer Managed Key (CMK)
- Attaching an appropriate policy to the CMK so that the IAM policies provisioned by this module can provide Vault servers access to the key
- (Optional) Provisioning a VPC endpoint for KMS in the appropriate subnets

You might want to consider using the [`vault-auto-unseal`](../vault-auto-unseal) helper module in
combination with the `core` module.

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

### Other Integrations

There are other integrations that add features to your cluster in this repository that are not
mentioned in this README.

### Upgrading and updating

In general, to upgrade or update the servers, you will have to update the packer template file,
build a new AMI, then update the terraform variables with the new AMI ID. Then, you can run
`terraform apply` to update the launch configuration.

Then, you will need to terminate the various instances for Auto Scaling Group to start
new instances with the updated launch configurations. You should do this ONE BY ONE, or at least be
mindful about the quorum and maximum number of instances that can be terminated each time. See
the [consensus table](https://www.consul.io/docs/internals/consensus.html#deployment-table) for
clarity in the quorum values.

#### Automated upgrade via script

You may choose to run the Python 3 `upgrade.py` script, which should not require additional
dependency installation, to upgrade the instances.

Currently only `consul`, `nomad-server` and `vault` services can be done in this way.

Before you run the upgrade script, make sure to have your AWS credentials (such as env vars) set up
correctly, to point to the right environment for the instance upgrade. You may also choose to
supply the environment variables while running the script, e.g.
`AWS_PROFILE=staging ./upgrade.py ...`.

The script will terminate every instance type one-by-one, which is the safest way to maintain
quorum in each of the service type. Additionally, the script will check that the new instance is up
and correctly connected to its respective service, before continuing with the upgrade process,
until all old instances in that service type have been terminated and upgraded with new ones.

A fast (and furious) mode has also been added to the script, which can be turned on with the flag
`--fast`. In this mode, the script will calculate the maximum number of instances to terminate
at runtime for the specified service, while still maintaining quorum even if the new instances
are unable to start up properly. Please take precaution when using this mode.

For `consul`, the command should look like this:

```bash
./upgrade.py consul --consul-addr https://consul.x.y
```

For `nomad-server`, the command should look like this:

```bash
./upgrade.py nomad-server --nomad-addr https://nomad.x.y
```

For `vault`, the command should look like this:

```bash
./upgrade.py vault \
    --consul-addr https://consul.x.y \
    --vault-ca-cert /path/to/environments/xxx/ca.pem"
```

For more information, run

```bash
./upgrade.py -h
```

#### Manual upgrading Consul

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

#### Manual upgrading Nomad Servers

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

#### Manual upgrading Nomad Clients

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

#### Manual upgrading Vault

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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allowed\_ssh\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow SSH connections | list | `<list>` | no |
| associate\_public\_ip\_address | If set to true, associate a public IP address with each EC2 Instance in the cluster. | string | `"true"` | no |
| client\_node\_class | Nomad Client Node Class name for cluster identification | string | `"nomad-client"` | no |
| cluster\_tag\_key | The tag the Consul EC2 Instances will look for to automatically discover each other and form a cluster. | string | `"consul-servers"` | no |
| consul\_allowed\_inbound\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Consul servers for API usage | list | n/a | yes |
| consul\_ami\_id | AMI ID for Consul servers | string | n/a | yes |
| consul\_api\_domain | Domain to access Consul HTTP API | string | n/a | yes |
| consul\_cluster\_name | Name of the Consul cluster to deploy | string | `"consul"` | no |
| consul\_cluster\_size | The number of Consul server nodes to deploy. We strongly recommend using 3 or 5. | string | `"3"` | no |
| consul\_instance\_type | Type of instances to deploy Consul servers and clients to | string | `"t2.medium"` | no |
| consul\_lb\_deregistration\_delay | The time to wait for in-flight requests to complete while deregistering a target. During this time, the state of the target is draining. | string | `"30"` | no |
| consul\_lb\_healthy\_threshold | The number of consecutive health checks successes required before considering an unhealthy target healthy (2-10). | string | `"2"` | no |
| consul\_lb\_interval | The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. | string | `"30"` | no |
| consul\_lb\_timeout | The amount of time, in seconds, during which no response means a failed health check (2-60 seconds). | string | `"5"` | no |
| consul\_lb\_unhealthy\_threshold | The number of consecutive health check failures required before considering a target unhealthy (2-10). | string | `"2"` | no |
| consul\_root\_volume\_size | The size, in GB, of the root EBS volume. | string | `"50"` | no |
| consul\_root\_volume\_type | The type of volume. Must be one of: standard, gp2, or io1. | string | `"gp2"` | no |
| consul\_subnets | List of subnets to launch Connsul servers in | list | n/a | yes |
| consul\_termination\_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | string | `"NewestInstance"` | no |
| consul\_user\_data | The user data for the Consul servers EC2 instances. If set to empty, the default template will be used | string | `""` | no |
| elb\_access\_log | Log Internal LB access to a S3 bucket | string | `"false"` | no |
| elb\_access\_log\_bucket | S3 bucket to log access to the internal LB to | string | n/a | yes |
| elb\_access\_log\_prefix | Prefix in the S3 bucket to log internal LB access | string | `""` | no |
| elb\_idle\_timeout | The time in seconds that the connection is allowed to be idle. Consul supports blocking requests that can last up to 600 seconds. Increase this to support that. | string | `"660"` | no |
| elb\_ssl\_policy | ELB SSL policy for HTTPs listeners. See https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html | string | `"ELBSecurityPolicy-TLS-1-2-2017-01"` | no |
| integration\_consul\_prefix | The Consul prefix used by the various integration scripts during initial instance boot. | string | `"terraform/"` | no |
| internal\_lb\_certificate\_arn | ARN of the certificate to use for the internal LB | string | n/a | yes |
| internal\_lb\_incoming\_cidr | A list of CIDR-formatted IP address ranges from which the internal Load balancer is allowed to listen to | list | n/a | yes |
| internal\_lb\_name | Name of the internal load balancer | string | `"internal"` | no |
| internal\_lb\_subnets | List of subnets to deploy the internal LB to | list | n/a | yes |
| nomad\_api\_domain | Domain to access Nomad REST API | string | n/a | yes |
| nomad\_client\_instance\_type | Type of instances to deploy Nomad servers to | string | `"t2.medium"` | no |
| nomad\_client\_subnets | List of subnets to launch Nomad clients in | list | n/a | yes |
| nomad\_client\_termination\_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | string | `"Default"` | no |
| nomad\_clients\_allowed\_inbound\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Nomad Clients servers for API usage | list | n/a | yes |
| nomad\_clients\_ami\_id | AMI ID for Nomad clients | string | n/a | yes |
| nomad\_clients\_desired | The desired number of Nomad client nodes to deploy. | string | `"6"` | no |
| nomad\_clients\_docker\_privileged | Flag to enable privileged mode for Docker agent on Nomad client | string | `"false"` | no |
| nomad\_clients\_max | The max number of Nomad client nodes to deploy. | string | `"8"` | no |
| nomad\_clients\_min | The minimum number of Nomad client nodes to deploy. | string | `"3"` | no |
| nomad\_clients\_root\_volume\_size | The size, in GB, of the root EBS volume. | string | `"50"` | no |
| nomad\_clients\_root\_volume\_type | The type of volume. Must be one of: standard, gp2, or io1. | string | `"gp2"` | no |
| nomad\_clients\_services\_inbound\_cidr | A list of CIDR-formatted IP address ranges (in addition to the VPC range) from which the services hosted on Nomad clients on ports 20000 to 32000 will accept connections from. | list | `<list>` | no |
| nomad\_clients\_user\_data | The user data for the Nomad clients EC2 instances. If set to empty, the default template will be used | string | `""` | no |
| nomad\_cluster\_name | The name of the Nomad cluster (e.g. nomad-servers-stage). This variable is used to namespace all resources created by this module. | string | `"nomad"` | no |
| nomad\_server\_instance\_type | Type of instances to deploy Nomad servers to | string | `"t2.medium"` | no |
| nomad\_server\_lb\_deregistration\_delay | The time to wait for in-flight requests to complete while deregistering a target. During this time, the state of the target is draining. | string | `"30"` | no |
| nomad\_server\_lb\_healthy\_threshold | The number of consecutive health checks successes required before considering an unhealthy target healthy (2-10). | string | `"2"` | no |
| nomad\_server\_lb\_interval | The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. | string | `"30"` | no |
| nomad\_server\_lb\_timeout | The amount of time, in seconds, during which no response means a failed health check (2-60 seconds). | string | `"5"` | no |
| nomad\_server\_lb\_unhealthy\_threshold | The number of consecutive health check failures required before considering a target unhealthy (2-10). | string | `"2"` | no |
| nomad\_server\_subnets | List of subnets to launch Nomad servers in | list | n/a | yes |
| nomad\_server\_termination\_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | string | `"NewestInstance"` | no |
| nomad\_servers\_allowed\_inbound\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Nomad Servers servers for API usage | list | n/a | yes |
| nomad\_servers\_ami\_id | AMI ID for Nomad servers | string | n/a | yes |
| nomad\_servers\_num | The number of Nomad server nodes to deploy. We strongly recommend using 3 or 5. | string | `"3"` | no |
| nomad\_servers\_root\_volume\_size | The size, in GB, of the root EBS volume. | string | `"50"` | no |
| nomad\_servers\_root\_volume\_type | The type of volume. Must be one of: standard, gp2, or io1. | string | `"gp2"` | no |
| nomad\_servers\_user\_data | The user data for the Nomad servers EC2 instances. If set to empty, the default template will be used | string | `""` | no |
| route53\_zone | Zone for Route 53 records | string | n/a | yes |
| ssh\_key\_name | The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair. | string | `""` | no |
| tags | A map of tags to add to all resources | map | `<map>` | no |
| use\_private\_zone | Add additional private zone on top of the default public one. Setting to true causes the DNS names of the services here to be registered under the private zone only. | string | `"false"` | no |
| vault\_allowed\_inbound\_cidr\_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Vault servers for API usage | list | n/a | yes |
| vault\_allowed\_inbound\_security\_group\_count | The number of entries in var.allowed_inbound_security_group_ids.   Ideally, this value could be computed dynamically,   but we pass this variable to a Terraform resource's 'count' property and   Terraform requires that 'count' be computed with literals or data sources only. | string | `"0"` | no |
| vault\_allowed\_inbound\_security\_group\_ids | A list of security group IDs that will be allowed to connect to Vault | list | `<list>` | no |
| vault\_ami\_id | AMI ID for Vault servers | string | n/a | yes |
| vault\_api\_domain | Domain to access Vault HTTP API | string | n/a | yes |
| vault\_auto\_unseal\_kms\_endpoint | A custom VPC endpoint for Vault to use for KMS as part of auto-unseal | string | `""` | no |
| vault\_auto\_unseal\_kms\_key\_arn | The ARN of the KMS key used for unsealing the Vault cluster | string | `""` | no |
| vault\_auto\_usneal\_kms\_key\_region | The AWS region where the encryption key lives. If unset, defaults to the current region | string | `""` | no |
| vault\_cluster\_name | The name of the Vault cluster (e.g. vault-stage). This variable is used to namespace all resources created by this module. | string | `"vault"` | no |
| vault\_cluster\_size | The number of nodes to have in the cluster. We strongly recommend setting this to 3 or 5. | string | `"3"` | no |
| vault\_enable\_auto\_unseal | Enable auto unseal of the Vault cluster | string | `"false"` | no |
| vault\_enable\_s3\_backend | Whether to configure an S3 storage backend for Vault in addition to Consul. | string | `"false"` | no |
| vault\_instance\_type | The type of EC2 Instances to run for each node in the cluster (e.g. t2.micro). | string | `"t2.medium"` | no |
| vault\_lb\_deregistration\_delay | The time to wait for in-flight requests to complete while deregistering a target. During this time, the state of the target is draining. | string | `"30"` | no |
| vault\_lb\_healthy\_threshold | The number of consecutive health checks successes required before considering an unhealthy target healthy (2-10). | string | `"2"` | no |
| vault\_lb\_interval | The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. | string | `"30"` | no |
| vault\_lb\_timeout | The amount of time, in seconds, during which no response means a failed health check (2-60 seconds). | string | `"5"` | no |
| vault\_lb\_unhealthy\_threshold | The number of consecutive health check failures required before considering a target unhealthy (2-10). | string | `"2"` | no |
| vault\_root\_volume\_size | The size, in GB, of the root EBS volume. | string | `"50"` | no |
| vault\_root\_volume\_type | The type of volume. Must be one of: standard, gp2, or io1. | string | `"gp2"` | no |
| vault\_s3\_bucket\_name | The name of the S3 bucket to create and use as a storage backend for Vault. Only used if 'vault_enable_s3_backend' is set to true. | string | `""` | no |
| vault\_subnets | List of subnets to launch Vault servers in | list | n/a | yes |
| vault\_termination\_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | string | `"NewestInstance"` | no |
| vault\_tls\_key\_policy\_arn | ARN of the IAM policy to allow the Vault EC2 instances to decrypt the encrypted TLS private key baked into the AMI. See README for more information. | string | n/a | yes |
| vault\_user\_data | The user data for the Vault servers EC2 instances. If set to empty, the default template will be used | string | `""` | no |
| vpc\_id | ID of the VPC to launch the module in | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| asg\_name\_consul\_servers | Name of Consul Server Autoscaling group |
| asg\_name\_nomad\_clients | Name of the Autoscaling group for Nomad Clients |
| asg\_name\_nomad\_servers | Name of Nomad Server Autoscaling group |
| consul\_api\_address | Address to access consul API |
| consul\_cluster\_tag\_key | Key that Consul Server Instances are tagged with for discovery |
| consul\_cluster\_tag\_value | Value that Consul Server Instances are tagged with for discovery |
| consul\_server\_default\_user\_data | Default launch configuration user data for Consul Server |
| consul\_server\_user\_data | Default launch configuration user data for Consul Server |
| iam\_role\_arn\_consul\_servers | IAM Role ARN for Consul servers |
| iam\_role\_arn\_nomad\_clients | IAM Role ARN for Nomad Clients |
| iam\_role\_arn\_nomad\_servers | IAM Role ARN for Nomad servers |
| iam\_role\_id\_consul\_servers | IAM Role ID for Consul servers |
| iam\_role\_id\_nomad\_clients | IAM Role ID for Nomad Clients |
| iam\_role\_id\_nomad\_servers | IAM Role ID for Nomad servers |
| internal\_lb\_dns\_name | DNS name of the internal LB |
| internal\_lb\_https\_listener\_arn | ARN of the HTTPS listener for the internal LB |
| internal\_lb\_id | ARN of the internal LB that exposes Nomad, Consul and Vault RPC |
| internal\_lb\_security\_group\_id | Security Group ID for the Internal LB |
| internal\_lb\_zone\_id | The canonical hosted zone ID of the internal load balancer |
| launch\_config\_name\_consul\_servers | Name of the Launch Configuration for Consul servers |
| launch\_config\_name\_nomad\_clients | Name of the Launch Configuration for Nomad Clients |
| launch\_config\_name\_nomad\_servers | Name of Launch Configuration for Nomad servers |
| node\_class\_nomad\_clients | Nomad Client Node Class name applied |
| nomad\_api\_address | Address to access nomad API |
| nomad\_client\_default\_user\_data | Default launch configuration user data for Nomad Client |
| nomad\_client\_user\_data | User data used by Nomad Client |
| nomad\_server\_default\_user\_data | Default launch configuration user data for Nomad Server |
| nomad\_server\_user\_data | User data used by Nomad Server |
| nomad\_servers\_cluster\_tag\_key | Key that Nomad Server Instances are tagged with for discovery |
| nomad\_servers\_cluster\_tag\_value | Value that Nomad servers are tagged with for discovery |
| num\_consul\_servers | Number of Consul servers in cluster |
| num\_nomad\_clients | The desired number of Nomad clients in cluster |
| num\_nomad\_servers | Number of Nomad servers in the cluster |
| private\_zone\_id | Private zone ID, only applicable when `use_private_zone` is set to true |
| security\_group\_id\_consul\_servers | Security Group ID for Consul servers |
| security\_group\_id\_nomad\_clients | Security Group ID for Nomad Clients |
| security\_group\_id\_nomad\_servers | Security Group ID for Nomad servers |
| ssh\_key\_name | The name of the SSH key that all instances are launched with |
| use\_private\_zone | Indicates if there is private zone used for the core setup |
| vault\_api\_address | Address to access Vault API |
| vault\_asg\_name | Name of the Autoscaling group for Vault cluster |
| vault\_cluster\_default\_user\_data | Default launch configuration user data for Vault Cluster |
| vault\_cluster\_size | Number of instances in the Vault cluster |
| vault\_cluster\_user\_data | User data used by Vault Cluster |
| vault\_iam\_role\_arn | IAM Role ARN for Vault |
| vault\_iam\_role\_id | IAM Role ID for Vault |
| vault\_launch\_config\_name | Name of the Launch Configuration for Vault cluster |
| vault\_s3\_bucket\_arn | ARN of the S3 bucket that Vault's state is stored |
| vault\_security\_group\_id | ID of the Security Group for Vault |
| vault\_servers\_cluster\_tag\_key | Key that Vault instances are tagged with |
| vault\_servers\_cluster\_tag\_value | Value that Vault instances are tagged with |
