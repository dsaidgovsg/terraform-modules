# Prometheus Server

This module sets up a Prometheus server with tight integrations with the other modules in this
repository.

## Packer Template

You will have to build an AMI with the [Packer template](packer/packer.json) provided.

```bash
packer build -var-file "your_vars.json" packer/packer.json
```

Ansible will be used to provision the AMI.

## Persistence

By default, Prometheus will be configured to write to `/mnt/data`, which the Terraform module will
create as a separate EBS volume that will be mounted onto the Prometheus EC2 instance. This will
ensure that the data from Prometheus is never lost when respawning the EC2 instance.

## Scraping

Prometheus will be configured to scrape targets from
[Consul](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#consul_sd_config).

Prometheus will be configured will scrape from targets in the `prometheus-client` service by default
on the path `/mertics` by default. The port of the Prometheus client will be the port that is
reported by the service.

In addition, you can add the following [tags](https://www.consul.io/docs/agent/services.html) in
the form of `<key>=<value>` to change the behaviour for scraping:

- `prometheus_path`: Change the path for scraping to anything else other than `/metrics`.

Any other keys that are prefixed with `prometheus_` will be added as labels for the target with
their prefixes removed.

## Important Variables

The following variables, available both in the Packer template and Terraform module unless otherwise
stated, are the more "important" variables that **must be equal** in both places for Prometheus to
work properly.

- `prometheus_client_service`: Name of the Prometheus clients to scrape from. Defaults to `prometheus-client`
- `prometheus_db_dir`: Path where the data for Prometheus will be stored. This will be where the EBS volume where data is persisted will be mounted. Defaults to `/mnt/data`.
- `prometheus_port`: Port at which the server will be listening to. Defaults to `9090`.

## Integration with other modules
