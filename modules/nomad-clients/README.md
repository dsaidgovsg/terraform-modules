# Nomad Clients

This module sets up an additional cluster of Nomad Clients after the initial cluster setup during
the bootstrap of the Core module.

You might want to deploy an additional Nomad Cluster with different instance types, configuration,
or just on different accounts for billing purposes.

## Core Integration

If you use the default `user_data` script (which is the same as the Core module) and the same Packer
template as the Core module, you will generally get the same set of integration.

For some other integrations listed below, you will have to define a new "server type" to enable
the integration. Refer to the documentation for additional information.

- [AWS Authentication](../aws-auth): This integration is required for many other integration.
- [`td-agent`](../td-agent)
- [Telegraf](../telegraf)
- [Vault SSH](../vault-ssh)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allowed_inbound_cidr_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow connections to Nomad Clients for API usage | list | - | yes |
| allowed_ssh_cidr_blocks | A list of CIDR-formatted IP address ranges from which the EC2 Instances will allow SSH connections | list | `<list>` | no |
| ami_id | AMI ID for Nomad clients | string | - | yes |
| associate_public_ip_address | If set to true, associate a public IP address with each EC2 Instance in the cluster. | string | `true` | no |
| client_node_class | Nomad Client Node Class name for cluster identification | string | `nomad-client` | no |
| clients_desired | The desired number of Nomad client nodes to deploy. | string | `6` | no |
| clients_max | The max number of Nomad client nodes to deploy. | string | `8` | no |
| clients_min | The minimum number of Nomad client nodes to deploy. | string | `3` | no |
| cluster_name | Name of the Nomad Clients cluster | string | `nomad-client` | no |
| cluster_tag_key | The tag the Consul EC2 Instances will look for to automatically discover each other and form a cluster. | string | `consul-servers` | no |
| consul_cluster_name | Name of the Consul cluster to deploy | string | `consul-nomad-prototype` | no |
| docker_privileged | Flag to enable privileged mode for Docker agent on Nomad client | string | `false` | no |
| instance_type | Type of instances to deploy Nomad servers to | string | `t2.medium` | no |
| integration_consul_prefix | The Consul prefix used by the various integration scripts during initial instance boot. | string | `terraform/` | no |
| integration_service_type | The 'server type' for this Nomad cluster. This is used in several integration. If empty, this defaults to the `cluster_name` variable | string | `` | no |
| nomad_clients_services_inbound_cidr | A list of CIDR-formatted IP address ranges (in addition to the VPC range) from which the services hosted on Nomad clients on ports 20000 to 32000 will accept connections from. | list | `<list>` | no |
| root_volume_size | The size, in GB, of the root EBS volume. | string | `50` | no |
| root_volume_type | The type of volume. Must be one of: standard, gp2, or io1. | string | `gp2` | no |
| ssh_key_name | The name of an EC2 Key Pair that can be used to SSH to the EC2 Instances in this cluster. Set to an empty string to not associate a Key Pair. | string | `` | no |
| termination_policies | A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default. | string | `Default` | no |
| user_data | The user data for the Nomad clients EC2 instances. If set to empty, the default template will be used | string | `` | no |
| vpc_id | ID of the VPC to deploy to | string | - | yes |
| vpc_subnet_ids | List of Subnet IDs to deploy to | list | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| asg_name | Name of auto-scaling group for Nomad Clients |
| client_node_class | Nomad Client Node Class name applied |
| cluster_size | Number of Nomad Clients in the cluster |
| default_user_data | Default launch configuration user data for Nomad Clients |
| iam_role_arn | IAM Role ARN for Nomad Clients |
| iam_role_id | IAM Role ID for Nomad Clients |
| launch_config_name | Name of launch config for Nomad Clients |
| security_group_id | Security group ID for Nomad Clients |
| ssh_key_name | Name of SSH Key for SSH login authentication to Nomad Clients cluster |
| user_data | User data used for Nomad Clients |
