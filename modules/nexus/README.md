# Prometheus Server

This module sets up a Nexus server with tight integrations with the other modules in this
repository.

## Packer Template

### Instance AMI

You will have to build an AMI with the [Packer template](packer/packer.json) provided.

```bash
packer build \
    -var-file "your_vars.json" \
    packer/ami/packer.json
```

Ansible will be used to provision the AMI.

### Data Volume Snapshot

You will need to use Packer to build a __one off__ data volume to hold your Prometheus data. You
will then need to provide the EBS volume ID to the Terraform module.

**Make sure you create the volume in the same availability zone as the instance you are going to run.**

```bash
packer build \
    -var-file "your_vars.json" \
    packer/data/packer.json
```

## Persistence

By default, Nexus will be configured to write to `/opt/sonatype/sonatype-work`, which the Terraform module will
create as a separate EBS volume that will be mounted onto the Nexus EC2 instance. This will
ensure that the data from Prometheus is never lost when respawning the EC2 instance.

## Integration with other modules

### Traefik

Automatic reverse proxy via Traefik can be enabled with the appropriate variables set.

### AWS Authentication

An AWS authentication role can be automatically created.

### Vault SSH

Access via SSH with Vault can be automatically configured.

### `td-agent`

If you would like to configure `td-agent` to automatically ship logs to your fluentd server, you
will have to provide a configuration file for `td-agent`.

You can use the recommended default template and variables by setting the following variables for
the Packer template:

- `td_agent_config_file`: Set this to `../td-agent/config/template/td-agent.conf`
- `td_agent_config_vars_file`: Set this to `packer/td-agent-vars.yml`.

For example, add the following arguments to `packer build`:

```bash
    --var "td_agent_config_file=$(pwd)/../td-agent/config/template/td-agent.conf" \
    --var "td_agent_config_vars_file=$(pwd)/packer/td-agent-vars.yml"
```

Refer to the module documentation for more details.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_cidr_blocks | Additional CIDR blocks other than the VPC CIDR block thatn can access the Nexus server | list | `<list>` | no |
| allowed_ssh_cidr_blocks | List of allowed CIDR blocks to allow SSH access | list | `<list>` | no |
| ami_id | AMI ID for Nexus Server | string | `` | no |
| associate_public_ip_address | Associate a public IP address for instance | string | `false` | no |
| aws_auth_enabled | Enable AWS Authentication | string | `false` | no |
| aws_auth_path | Path to the Vault AWS Authentication backend | string | `aws` | no |
| aws_auth_period_minutes | Period, in minutes, that the Vault token issued will live for | string | `60` | no |
| aws_auth_policies | List of Vault policies to assign to the tokens issued by the AWS authentication backend | list | `<list>` | no |
| aws_auth_vault_role | Name of the role in the AWS Authentication backend to create | string | `nexus` | no |
| consul_cluster_tag_key | Key that Consul Server Instances are tagged with for discovery | string | `consul-servers` | no |
| consul_cluster_tag_value | Value that Consul Server Instances are tagged with for discovery | string | `consul` | no |
| consul_key_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has         been applied. If you change this, you have to update the         `integration_consul_prefix` variable in the core module as well. | string | `terraform/` | no |
| consul_security_group_id | Security Group ID for Consul servers | string | - | yes |
| curator_age | Age in days to retain indices | string | `90` | no |
| curator_enable | Enable Curator integration for Nexus | string | `false` | no |
| curator_prefix | Elasticsearch prefix for Curator logs | string | `services.nexus` | no |
| data_device_name | Path of the EBS device that is mounted | string | `/dev/nvme1n1` | no |
| data_volume_id | EBS Volume ID for Nexus Data Storage | string | - | yes |
| data_volume_mount | Data volume mount device name | string | `/dev/sdf` | no |
| instance_type | Type of instance to deploy | string | `c5.large` | no |
| name | Base name for resources | string | `nexus` | no |
| nexus_ami_prefix | AMI ID prefix for Nexus | string | `nexus` | no |
| nexus_db_dir | Path where the data for Nexus will be stored. This will be where the EBS volume where data is persisted will be mounted. | string | `/opt/sonatype/sonatype-work` | no |
| nexus_port | Port at which the server will be listening to. | string | `8081` | no |
| nexus_service | Name of Nexus server service to register in Consul. | string | `nexus` | no |
| root_volume_size | Size of the Nexus server root volume in GB | string | `50` | no |
| server_type | Server type for the various types of modules integration | string | `nexus` | no |
| ssh_key_name | Name of SSH key to assign to the instance | string | - | yes |
| subdomain | Subdomain for Nexus server | string | `nexus` | no |
| subnet_id | Subnet ID to deploy the instance to | string | - | yes |
| tags | Tags to apply to resources | map | `<map>` | no |
| td_agent_enabled | Enable td-agent integration. You will still need to provide the appropriate configuration file for td-agent during the AMI building process. | string | `false` | no |
| traefik_enabled | Enable Traefik Integration | string | `false` | no |
| traefik_entrypoints | List of entrypoints for Traefik | list | `<list>` | no |
| traefik_fqdns | List of FQDNs for Traefik to listen to. You have to create the DNS records separately. | list | `<list>` | no |
| vault_ssh_enabled | Enable Vault SSH integration | string | `false` | no |
| vault_ssh_max_ttl | Max TTL for certificate renewal | string | `86400` | no |
| vault_ssh_path | Path to mount the SSH secrets engine | string | `ssh_nexus` | no |
| vault_ssh_role_name | Role name for the Vault SSH secrets engine | string | `default` | no |
| vault_ssh_ttl | TTL for the Vault SSH certificate in seconds | string | `300` | no |
| vault_ssh_user | Username to allow SSH access | string | `ubuntu` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | Instance ID for the server |
| instance_private_ip | Private IP address for the server |
| security_group_id | Security Group ID for the instance |
