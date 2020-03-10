# AWS Elasticsearch-post module

This module provides the additional Consul registration and redirection to Kibana to
an already running Elasticsearch module. This should be run only after Elasticsearch
and Core are up.

## Registered `consul` service name

The registered `consul` service name is `elasticsearch`, and the default port
used is `443`.

The actual VPC service and port are registered in `consul`. Any other services
that require Elasticsearch service should always use the actual VPC service
name, since the service is hosted under SSL and the SSL certificate to accept is
registered under the VPC name (and not the `consul` service name).

## Redirection

The module can optionally setup an ELB listener rule to redirect users to the Kibana interface
using a much friendlier URL.

We recommend that you use the internal ELB that was created by the `Core` module. For example, the
list below will list the pairs of variables in this module that can use the output from the `Core`
module:

- `var.lb_cname`: `module.core.internal_lb_dns_name`
- `var.lb_zone_id`: `module.core.internal_lb_zone_id`
- `var.redirect_listener_arn`: `module.core.internal_lb_https_listener_arn`

## Inputs and Outputs

Refer to [INOUT.md](INOUT.md)
