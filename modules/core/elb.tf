locals {
  private_zone_id = join("", aws_route53_zone.private.*.zone_id)
}

##############################
# Define an internal load balancer for API access to Nomad and Consul
##############################

# Internal Load balancer
resource "aws_lb" "internal" {
  name            = var.internal_lb_name
  security_groups = [aws_security_group.internal_lb.id]
  subnets         = var.internal_lb_subnets
  internal        = true

  idle_timeout = var.elb_idle_timeout

  access_logs {
    enabled = var.elb_access_log
    bucket  = var.elb_access_log_bucket
    prefix  = var.elb_access_log_prefix
  }

  drop_invalid_header_fields = var.internal_lb_drop_invalid_header_fields

  tags = merge(var.tags, { Name = var.internal_lb_name })
}

resource "aws_lb_listener" "internal_http" {
  count = var.enable_http ? 1 : 0

  load_balancer_arn = aws_lb.internal.arn
  port              = "80"
  protocol          = "HTTP"

  # Redirect to HTTPS
  default_action {
    type = "redirect"

    redirect {
      protocol    = "HTTPS"
      port        = 443
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "internal_https" {
  load_balancer_arn = aws_lb.internal.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.elb_ssl_policy
  certificate_arn   = var.internal_lb_certificate_arn

  # Redirect to a sink target group with zero targets
  default_action {
    target_group_arn = aws_lb_target_group.sink.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "sink" {
  name_prefix          = "sink"
  port                 = "80"
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = "30" # It doesn't matter

  tags = merge(var.tags, { Name = "${var.internal_lb_name}-sink" })

  lifecycle {
    create_before_destroy = true
  }
}

# Security group for the Internal LB
resource "aws_security_group" "internal_lb" {
  name        = var.internal_lb_name
  description = "Security group for Internal Load balancer for Nomad"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = var.internal_lb_name })
}

resource "aws_security_group_rule" "internal_http_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.internal_lb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = concat([data.aws_vpc.this.cidr_block], var.internal_lb_incoming_cidr)
}

resource "aws_security_group_rule" "internal_https_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.internal_lb.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = concat([data.aws_vpc.this.cidr_block], var.internal_lb_incoming_cidr)
}

##############################
# Nomad Server Access
##############################

resource "aws_lb_listener_rule" "nomad_server" {
  listener_arn = aws_lb_listener.internal_https.arn
  priority     = "1"

  action {
    target_group_arn = aws_lb_target_group.nomad_server.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = [var.nomad_api_domain]
    }
  }
}

resource "aws_lb_target_group" "nomad_server" {
  name_prefix          = "nomad"
  port                 = local.nomad_server_http_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = var.nomad_server_lb_deregistration_delay

  health_check {
    healthy_threshold   = var.nomad_server_lb_healthy_threshold
    matcher             = "200"
    timeout             = var.nomad_server_lb_timeout
    unhealthy_threshold = var.nomad_server_lb_unhealthy_threshold
    path                = "/v1/status/leader"
    port                = local.nomad_server_http_port
    interval            = var.nomad_server_lb_interval
  }

  stickiness {
    type    = "lb_cookie"
    enabled = true
  }

  tags = merge(var.tags, { Name = "${var.internal_lb_name}-nomad-server" })

  lifecycle {
    create_before_destroy = true
  }
}

# Attach target group to the Nomad servers ASG
resource "aws_autoscaling_attachment" "nomad_server_internal" {
  autoscaling_group_name = module.nomad_servers.asg_name
  alb_target_group_arn   = aws_lb_target_group.nomad_server.arn
}

resource "aws_security_group_rule" "nomad_api_outgoing" {
  type                     = "egress"
  security_group_id        = aws_security_group.internal_lb.id
  from_port                = local.nomad_server_http_port
  to_port                  = local.nomad_server_http_port
  protocol                 = "tcp"
  source_security_group_id = module.nomad_servers.security_group_id
}

# Security rules for Nomad servers to be accessible by the internal LB
resource "aws_security_group_rule" "nomad_http" {
  type                     = "ingress"
  security_group_id        = module.nomad_servers.security_group_id
  from_port                = local.nomad_server_http_port
  to_port                  = local.nomad_server_http_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.internal_lb.id
}

# A Record for nomad API endpoint to point to Internal Load balancer
resource "aws_route53_record" "nomad_rpc" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = var.nomad_api_domain
  type    = "A"

  alias {
    name                   = aws_lb.internal.dns_name
    zone_id                = aws_lb.internal.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "private_zone_nomad_rpc" {
  count = var.add_private_route53_zone ? 1 : 0

  zone_id = local.private_zone_id
  name    = var.nomad_api_domain
  type    = "A"

  alias {
    name                   = aws_lb.internal.dns_name
    zone_id                = aws_lb.internal.zone_id
    evaluate_target_health = false
  }
}

##############################
# Consul Server Access
##############################
resource "aws_lb_listener_rule" "consul_server" {
  listener_arn = aws_lb_listener.internal_https.arn
  priority     = "2"

  action {
    target_group_arn = aws_lb_target_group.consul_servers.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = [var.consul_api_domain]
    }
  }
}

resource "aws_lb_target_group" "consul_servers" {
  name_prefix          = "consul"
  port                 = local.consul_http_api_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = var.consul_lb_deregistration_delay

  health_check {
    healthy_threshold   = var.consul_lb_healthy_threshold
    matcher             = "200"
    timeout             = var.consul_lb_timeout
    unhealthy_threshold = var.consul_lb_unhealthy_threshold
    path                = "/v1/status/leader"
    port                = local.consul_http_api_port
    interval            = var.consul_lb_interval
  }

  stickiness {
    type    = "lb_cookie"
    enabled = true
  }

  tags = merge(var.tags, { Name = "${var.internal_lb_name}-consul-server" })

  lifecycle {
    create_before_destroy = true
  }
}

# Attach target group to the Consul servers ASG
resource "aws_autoscaling_attachment" "consul_server_internal" {
  autoscaling_group_name = module.consul_servers.asg_name
  alb_target_group_arn   = aws_lb_target_group.consul_servers.arn
}

resource "aws_security_group_rule" "consul_api_outgoing" {
  type                     = "egress"
  security_group_id        = aws_security_group.internal_lb.id
  from_port                = local.consul_http_api_port
  to_port                  = local.consul_http_api_port
  protocol                 = "tcp"
  source_security_group_id = module.consul_servers.security_group_id
}

# Security rules for Consul servers to be accessible by the internal LB
resource "aws_security_group_rule" "consul_http" {
  type                     = "ingress"
  security_group_id        = module.consul_servers.security_group_id
  from_port                = local.consul_http_api_port
  to_port                  = local.consul_http_api_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.internal_lb.id
}

resource "aws_route53_record" "consul" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = var.consul_api_domain
  type    = "A"

  alias {
    name                   = aws_lb.internal.dns_name
    zone_id                = aws_lb.internal.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "private_zone_consul" {
  count = var.add_private_route53_zone ? 1 : 0

  zone_id = local.private_zone_id
  name    = var.consul_api_domain
  type    = "A"

  alias {
    name                   = aws_lb.internal.dns_name
    zone_id                = aws_lb.internal.zone_id
    evaluate_target_health = false
  }
}

##############################
# Vault Server Access
##############################
resource "aws_lb_listener_rule" "vault" {
  listener_arn = aws_lb_listener.internal_https.arn
  priority     = "3"

  action {
    target_group_arn = aws_lb_target_group.vault.arn
    type             = "forward"
  }

  condition {
    host_header {
      values = [var.vault_api_domain]
    }
  }
}

resource "aws_lb_target_group" "vault" {
  name_prefix          = "vault"
  port                 = local.vault_lb_port
  protocol             = "HTTPS"
  vpc_id               = var.vpc_id
  deregistration_delay = var.vault_lb_deregistration_delay

  health_check {
    healthy_threshold   = var.vault_lb_healthy_threshold
    matcher             = "200"
    timeout             = var.vault_lb_timeout
    unhealthy_threshold = var.vault_lb_unhealthy_threshold
    protocol            = "HTTPS"
    path                = "/v1/sys/health?standbyok=true"
    port                = local.vault_lb_port
    interval            = var.vault_lb_interval
  }

  stickiness {
    type    = "lb_cookie"
    enabled = true
  }

  tags = merge(var.tags, { Name = "${var.internal_lb_name}-vault" })

  lifecycle {
    create_before_destroy = true
  }
}

# Attach target group to the Vault servers ASG
resource "aws_autoscaling_attachment" "vault_internal" {
  autoscaling_group_name = module.vault.asg_name
  alb_target_group_arn   = aws_lb_target_group.vault.arn
}

resource "aws_security_group_rule" "vault_api_outgoing" {
  type                     = "egress"
  security_group_id        = aws_security_group.internal_lb.id
  from_port                = local.vault_lb_port
  to_port                  = local.vault_lb_port
  protocol                 = "tcp"
  source_security_group_id = module.vault.security_group_id
}

# Security rules for Vault servers to be accessible by the internal LB
resource "aws_security_group_rule" "vault_https" {
  type                     = "ingress"
  security_group_id        = module.vault.security_group_id
  from_port                = local.vault_lb_port
  to_port                  = local.vault_lb_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.internal_lb.id
}

resource "aws_route53_record" "vault" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = var.vault_api_domain
  type    = "A"

  alias {
    name                   = aws_lb.internal.dns_name
    zone_id                = aws_lb.internal.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "private_zone_vault" {
  count = var.add_private_route53_zone ? 1 : 0

  zone_id = local.private_zone_id
  name    = var.vault_api_domain
  type    = "A"

  alias {
    name                   = aws_lb.internal.dns_name
    zone_id                = aws_lb.internal.zone_id
    evaluate_target_health = false
  }
}
