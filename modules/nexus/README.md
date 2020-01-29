# Nexus Server

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

You will need to use Packer to build a __one off__ data volume to hold your Nexus data. You
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
ensure that the data from Nexus is never lost when respawning the EC2 instance.

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

## Inputs and Outputs

Refer to [INOUT.md](INOUT.md)
