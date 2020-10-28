# Fluentd Server

This module sets up a Fluentd server running on an autoscaling cluster which forwards 
logs from other modules to S3 and Elasticsearch.

## Requirements

- [Elasticsearch module](../elasticsearch)
- [Fluentd_pre module](../fluentd_pre) which builds the AMI to run on this cluster.

## Default settings

By default, `fluentd` is configured to match tags from logs sent from the example configuration
provided in the [`td-agent`](../td-agent) module. See the module for more information on how to
configure your instances to forward logs to fluentd. It also match logs tagged with `docker.*` for
your Nomad jobs.

You can change the matched tags with the `fluentd_match` variable.

## Applying the module

There are some things to take note of before applying the module other than the requirements above.

### Fluentd port

Fluentd will statically bind itself to a port of your choice via the `fluentd_port` variable on your
Nomad clients.

In order for your applications to forward logs to your Fluentd servers, you will have to define
additional security group rules to your Nomad clients cluster.

## Forwarding Logs

You can use the [td-agent module](../td-agent) along with the example configuration files to forward
logs from your Consul Servers, Nomad Servers, Nomad Clients, and Vault Servers to Fluentd.

If you would like to forward logs from your Nomad jobs, you might want to tag them with
`docker.XXX`.

For example, in your Jobspec, you can use:

```hcl
job "job" {
  # ...
  group "group" {
    # ...
    task "task" {
      # ...
      driver = "docker"

      config = {
        logging {
          type = "fluentd"

          config = {
            fluentd-address = "<fluentd-hostname>:4224"
            tag             = "docker.job"
          }
        }
      }
    }
  }
}
```

## Inputs and Outputs

Refer to [INOUT.md](INOUT.md)
