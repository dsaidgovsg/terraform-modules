# Deploy Nomad, Vault and Consul clusters using Terraform

This is based on the
[example](https://github.com/hashicorp/terraform-aws-nomad/tree/master/examples/nomad-consul-separate-cluster)
by Hashicorp.

The vault deployment is based off this
[example](https://github.com/hashicorp/terraform-aws-vault/tree/master/examples/vault-cluster-private).

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

- Create a VPC on AWS with at least one subnet per availability zone
- Have a domain either registered with AWS Route 53 or other registrar.
- Create an AWS Hosted zone for the domain or subdomain. If the domain is registered with another registrar, it must have its name servers set to AWS.
- Use AWS Certficate Manager to request certificates for the domain and its wildcard subdomains. For example, you need to request a certificate that contains the names `nomad.gahmen.tech` AND `*.nomad.gahmen.tech`.

## Building AMIs

We first need to use [packer](https://www.packer.io/) to build three AMIs:

- [Consul](package/consul])
- [Consul and Nomad](packer/nomad)
- [Consul and Vault](packer/vault)

Read [this](https://www.packer.io/docs/builders/amazon.html#specifying-amazon-credentials) on how
to specify AWS credentials.

Refer to each of the directories for instruction.

Take note of the AMI IDs returned from this.

## Defining Variables

You should refer to `variables.tf` and then create your own
[variable file](https://www.terraform.io/intro/getting-started/variables.html#from-a-file).

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

## TODOs

- Update the terraform modules to create the VPC too.
- [Transport Encryption](https://github.com/hashicorp/terraform-aws-nomad/tree/master/modules/run-nomad#how-do-you-handle-encryption)
- [Vault](https://github.com/hashicorp/terraform-aws-vault)
- Use CloudWatch for ELB/ASG alerts to be published to a SNS topic. Have the SNS topic send invoke
a lambda to send a message to Telegram/Slack?
- Consider moving Consul and Nomad servers into private subnet
- [Store Terraform state on S3](https://www.terraform.io/docs/backends/types/s3.html) and workspaces
- [Nomad and Consul UI](https://github.com/jrasell/nomadfiles/blob/master/hashi-ui/hashi-ui.nomad)
- [Automatic Job scaling](https://github.com/elsevier-core-engineering/replicator)
- Ansible playbooks to manage cluster (e.g. terminate all workers etc.)
- Internal load balancer for Nomad and Consul APIs
- AWS Health checks improvements
- [Monitoring and telemetry](https://blog.takipi.com/graphite-vs-grafana-build-the-best-monitoring-architecture-for-your-application/)

### Nginx Reverse Proxy for Web Applications

Fronted by Elastic Load Balancer (ELB) with a Target group tied to Nomad client's Auto scaling group.
Then, deploy as many replicas of Nginx as needed for HA and statically bind them to, say, port 80.
The Nomad client nodes with port 80 accessible will become `healthy` in the eyes of ELB and then
ELB will route to them as necessary.

The Nginx proxy will have to be powered by `consul-template`.
[Example](https://github.com/hashicorp/consul-template/blob/063041f05c95a90cacd322dcfc14cd0ab83f5734/examples/nginx.md)

Alternatively, consider some service that will watch consul and update ELB via the AWS API:

- [Python](https://github.com/sebest/docker-elb-consul)
- [Go](https://github.com/pshima/consul-alb-sync)

Or consider the following products:

- [Traefik](https://traefik.io/)
- [fabio](https://github.com/fabiolb/fabio)

Or we can skip ELB directly, and use
[Route 53 with health checks](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/dns-failover.html)
to the Nginx machines.

### Public facing SSL certificates for ELB or other load balancer

- [AWS Certificatre Manager](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-request.html)
- [Let's Encrypt imported into ACM](https://github.com/alex/letsencrypt-aws)
(Also needs `route53:ListHostedZonesByName` IAM permission)

### Persistent Storage

- [GlusterFS?](https://github.com/hashicorp/nomad/issues/150#issuecomment-344412873)
- [`ephemeral_disk`](https://www.nomadproject.io/docs/job-specification/ephemeral_disk.html)

## Resources

- [Awesome Nomad](https://github.com/jippi/awesome-nomad)

## Upgrading

In general, to upgrade the servers, you will have to update the packer template file, build
a new AMI, the update the terraform variables with the new AMI ID. Then, you can run
`terraform apply` to update the launch configuration.

Then, you will need to terminate the various instances for Auto Scaling Group to start
new instances with the updated launch configurations. You should do this ONE BY ONE.

### Upgrading Consul

1. Terminate the instance that you would like to remove.
1. The Consul server will gracefully exit, and cause the node to become unhealthy, and AWS will automatically start a new instance.

### Upgrading Nomad Servers

1. Terminate the instance that you would like to remove.
1. The nomad server will gracefully exit, and cause the node to become unhealthy, and AWS will automatically start a new instance.

### Upgrading Nomad Clients

When draining Nomad client nodes, users will experience momentary downtime as ELB catches up with
the unhealthy client status.

1. Drain the servers using `nomad node-drain node-id`
1. After the allocations are drained, terminate the instance and AWS will launch a new instance.
