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
only. Most importantly, take note of the `tags` key of the `service` stanza. You must also
remember to create DNS records to point to the ELB provisioned by this module.

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
          "traefik.frontend.rule=Host:hashi-ui.example.com",
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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| access_log_enable | Enable access logging | string | `true` | no |
| access_log_json | Log access in JSON | string | `false` | no |
| additional_docker_config | Additional HCL to be added to the configuration for the Docker driver. Refer to the template Jobspec for what is already defined | string | `` | no |
| deregistration_delay | Time before an unhealthy Elastic Load Balancer target becomes removed | string | `60` | no |
| elb_ssl_policy | ELB SSL policy for HTTPs listeners. See https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html | string | `ELBSecurityPolicy-TLS-1-2-2017-01` | no |
| external_certificate_arn | ARN for the certificate to use for the external LB | string | - | yes |
| external_lb_incoming_cidr | A list of CIDR-formatted IP address ranges from which the external Load balancer is allowed to listen to | list | `<list>` | no |
| external_lb_name | Name of the external Nomad load balancer | string | `traefik-external` | no |
| external_nomad_clients_asg | The Nomad Clients Autoscaling group to attach the external load balancer to | string | - | yes |
| healthy_threshold | The number of consecutive health checks successes required before considering an unhealthy target healthy (2-10). | string | `2` | no |
| internal_certificate_arn | ARN for the certificate to use for the internal LB | string | - | yes |
| internal_lb_incoming_cidr | A list of CIDR-formatted IP address ranges from which the internal load balancer is allowed to listen to | list | `<list>` | no |
| internal_lb_name | Name of the external Nomad load balancer | string | `traefik-internal` | no |
| internal_nomad_clients_asg | The Nomad Clients Autoscaling group to attach the internal load balancer to | string | - | yes |
| interval | The approximate amount of time, in seconds, between health checks of an individual target. Minimum value 5 seconds, Maximum value 300 seconds. | string | `30` | no |
| log_json | Log in JSON format | string | `false` | no |
| nomad_clients_external_security_group | The security group of the nomad clients that the external LB will be able to connect to | string | - | yes |
| nomad_clients_internal_security_group | The security group of the nomad clients that the internal LB will be able to connect to | string | - | yes |
| nomad_clients_node_class | Job constraint Nomad Client Node Class name | string | - | yes |
| route53_zone | Zone for Route 53 records | string | - | yes |
| subnets | List of subnets to deploy the LB to | list | - | yes |
| tags | A map of tags to add to all resources | string | `<map>` | no |
| timeout | The amount of time, in seconds, during which no response means a failed health check (2-60 seconds). | string | `5` | no |
| traefik_consul_catalog_prefix | Prefix for Consul catalog tags for Traefik | string | `traefik` | no |
| traefik_consul_prefix | Prefix on Consul to store Traefik configuration to | string | `traefik` | no |
| traefik_count | Number of copies of Traefik to run | string | `3` | no |
| traefik_external_base_domain | Domain to expose the external Traefik load balancer | string | - | yes |
| traefik_internal_base_domain | Domain to expose the external Traefik load balancer | string | - | yes |
| traefik_priority | Priority of the Nomad job for Traefik. See https://www.nomadproject.io/docs/job-specification/job.html#priority | string | `50` | no |
| traefik_ui_domain | Domain to access Traefik UI | string | - | yes |
| traefik_version | Docker image tag of the version of Traefik to run | string | `v1.6.5-alpine` | no |
| unhealthy_threshold | The number of consecutive health check failures required before considering a target unhealthy (2-10). | string | `2` | no |
| vpc_id | ID of the VPC to deploy the LB to | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| traefik_external_cname | URL that applications should set a CNAME record to for Traefik reverse proxy |
| traefik_external_lb_dns | URL that applications should set a CNAME or ALIAS record to the external LB directly |
| traefik_external_zone | The canonical hosted zone ID of the external load balancer (to be used in a Route 53 Alias record). |
| traefik_internal_cname | URL that applications should set a CNAME record to for Traefik reverse proxy |
| traefik_internal_lb_dns | URL that applications should set a CNAME or ALIAS record to the internal LB directly |
| traefik_internal_zone | The canonical hosted zone ID of the internal load balancer (to be used in a Route 53 Alias record). |
| traefik_jobspec | Nomad Jobspec for the deployed Traefik reverse proxy |
| traefik_lb_external_https_listener_arn | ARN of the HTTPS listener for the external load balancer |
| traefik_lb_internal_https_listener_arn | ARN of the HTTPS listener for the internal load balancer |
