# Traefik Module

This module provisions the [Traefik](https://traefik.io/) reverse proxy that automatically creates
routes from an ELB to your applications through Consul Service Catalog.

You might want to familiarise yourself with some [concepts](https://docs.traefik.io/basics/)
from Traefik before continuing.

## Integration with `Core` module

This module is integrated with the `core` module to enable you to use both in conjunction
seamlessly.

## Pre-requisites

Make sure you have a certificate (preferably Wildcard) in ACM to provide to this module to use in
front of the load balancer as the default certificate.

If you have additional certificates you would like to attach to the load balancer, you can provision
them with the
[`aws_lb_listener_certificate`](https://www.terraform.io/docs/providers/aws/r/lb_listener_certificate.html)
resource.

## Applying the Module

If you have enabled ACL for your Nomad cluster, you will need to provide the token to the
[Nomad provider](https://www.terraform.io/docs/providers/nomad/index.html).

## Traefik Entrypoints

This module creates two entrypoints for your applications to use:

- `http`: External endpoint for all applications to be accessed via the internet.
- `internal`: Internal endpoint that is only accessible from within your VPC.

## Writing a Job for Traefik

Traefik knows when to create routes based on the
[tags](https://www.consul.io/docs/agent/services.html) on your Consul services. You can see the full
list of options that Traefik recognises on the
[documentation](https://docs.traefik.io/configuration/backends/consulcatalog/).

The example Nomad jobspec below shows how one might want to deploy
[hashi-ui](https://github.com/jippi/hashi-ui) on the internal entrypoint for your internal users
only. Most importantly, take note of the `tags` key of the `service` stanza.

```hcl
job "hashi-ui" {
  datacenters = ["ap-southeast-1a","ap-southeast-1b","ap-southeast-1c"]
  region      = "ap-southeast-1"
  type        = "service"

  update {
    max_parallel = 1
    min_healthy_time = "30s"
    healthy_deadline = "10m"
    auto_revert = true
  }

  group "server" {
    count = 2

    task "hashi-ui" {
      driver = "docker"

      config {
        image = "jippi/hashi-ui:v0.25.0"
        port_map {
          http = 3000
        }

        dns_servers = ["169.254.1.1"]
      }

      service {
        port = "http"

        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }

        tags = [
          "traefik.enable=true",
          "traefik.frontend.rule=Host:hashi-ui.locus.rocks",
          "traefik.frontend.entryPoints=internal",
          "traefik.frontend.headers.SSLRedirect=true",
          "traefik.frontend.headers.SSLProxyHeaders=X-Forwarded-Proto:https",
          "traefik.frontend.headers.STSSeconds=315360000",
          "traefik.frontend.headers.frameDeny=true"
        ]
      }

      env {
        NOMAD_ENABLE = 1
        NOMAD_ADDR  = "http://http.nomad.service.consul:4646"
        NOMAD_READ_ONLY = "true"

        CONSUL_ENABLE = 1
        CONSUL_ADDR = "consul.service.consul:8500"
      }

      resources {
        cpu    = 500
        memory = 512

        network {
          mbits = 5

          port  "http"{}
        }
      }
    }
  }
}
```
