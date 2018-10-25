# Curator

This module runs [Curator](https://github.com/elastic/curator) as a Cron job in Nomad to clean up
old indices in your Elasticsearch cluster.

## Requirements

- Core
- Elasticsearch cluster — You can optionally choose to use the [elasticsearch module](../elasticsearch) to run your cluster

## Default settings

By default, `curator` is configured to match tags from logs sent from the example configuration
provided in the [`td-agent`](../td-agent) module. It also matches logs tagged with `docker.*` for
your Nomad jobs.

If you have custom prefix or suffix to define, consider using the `actions` submodule in this
module.

## Docker Image

You should build a Docker image from the official [repository](https://github.com/elastic/curator)
and push it to your own Docker Registry. Then, configure the relevant entrypoints and arguments.

The default entrypoints and arguments assumes an image built from the official repository.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| actions_path | Path to render the actions file in the Docker container | string | `/config/actions.yml` | no |
| additional_docker_config | Additional HCL to be added to the configuration for the Docker driver. Refer to the template Jobspec for what is already defined | string | `` | no |
| args | Arguments for the Docker image | string | `<list>` | no |
| command | Command for the Docker Image | string | `/curator/curator` | no |
| config_path | Path to render the configuration file in the Docker container | string | `/config/config.yml` | no |
| consul_age | Age in days to clear Consul server log indices | string | `90` | no |
| consul_disable | Disable clearing Consul server log indices | string | `false` | no |
| consul_key_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has         been applied. If you change this, you have to update the         `integration_consul_prefix` variable in the core module as well. | string | `terraform/` | no |
| consul_prefix | Prefix for Consul server logs | string | `services.consul.` | no |
| consul_template_age | Age in days to clear consul_template log indices | string | `90` | no |
| consul_template_disable | Disable clearing consul_template log indices | string | `false` | no |
| consul_template_prefix | Prefix for consul_template logs | string | `services.consul-template.` | no |
| cron | Cron job schedule. See https://www.nomadproject.io/docs/job-specification/periodic.html#cron | string | `@weekly` | no |
| cron_age | Age in days to clear cron log indices | string | `90` | no |
| cron_disable | Disable clearing cron log indices | string | `false` | no |
| cron_prefix | Prefix for cron logs | string | `system.cron.` | no |
| docker_age | Age in days to clear docker log indices | string | `90` | no |
| docker_disable | Disable clearing docker log indices | string | `false` | no |
| docker_image | Docker Image to run the job | string | - | yes |
| docker_prefix | Prefix for docker logs | string | `docker.` | no |
| docker_tag | Docker tag to run | string | `latest` | no |
| elasticsearch_service | Name of the Elasticsearch service to lookup in Consul | string | `elasticsearch` | no |
| entrypoint | Entrypoint for the Docker Image | string | `/bin/sh` | no |
| force_pull | Force Nomad Clients to always force pull | string | `false` | no |
| job_name | Name of the Nomad Job | string | `curator` | no |
| nomad_age | Age in days to clear nomad log indices | string | `90` | no |
| nomad_clients_node_class | Job constraint Nomad Client Node Class name | string | - | yes |
| nomad_disable | Disable clearing nomad log indices | string | `false` | no |
| nomad_prefix | Prefix for nomad logs | string | `services.nomad.` | no |
| sshd_age | Age in days to clear sshd log indices | string | `90` | no |
| sshd_disable | Disable clearing sshd log indices | string | `false` | no |
| sshd_prefix | Prefix for sshd logs | string | `system.sshd.` | no |
| sudo_age | Age in days to clear sudo log indices | string | `90` | no |
| sudo_disable | Disable clearing sudo log indices | string | `false` | no |
| sudo_prefix | Prefix for sudo logs | string | `system.sudo.` | no |
| td_agent_age | Age in days to clear td_agent log indices | string | `90` | no |
| td_agent_disable | Disable clearing td_agent log indices | string | `false` | no |
| td_agent_prefix | Prefix for td_agent logs | string | `system.td-agent.` | no |
| telegraf_age | Age in days to clear telegraf log indices | string | `90` | no |
| telegraf_disable | Disable clearing telegraf log indices | string | `false` | no |
| telegraf_prefix | Prefix for telegraf logs | string | `system.telegraf.` | no |
| timezone | Timezone to run cron job scheduling | string | `Asia/Singapore` | no |
| vault_age | Age in days to clear vault log indices | string | `90` | no |
| vault_disable | Disable clearing vault log indices | string | `false` | no |
| vault_prefix | Prefix for vault logs | string | `services.vault.` | no |
