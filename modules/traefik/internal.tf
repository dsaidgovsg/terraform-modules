###################################################################################################
# Traefik Internal Reverse Proxy
###################################################################################################

resource "aws_lb" "internal" {
  name            = var.internal_lb_name
  internal        = true
  security_groups = [aws_security_group.internal_lb.id]
  subnets         = var.lb_internal_subnets

  access_logs {
    enabled = var.lb_internal_access_log
    bucket  = var.lb_internal_access_log_bucket
    prefix  = var.lb_internal_access_log_prefix
  }

  tags = merge(var.tags, { Name = var.internal_lb_name })
}

resource "aws_security_group" "internal_lb" {
  name        = "${var.internal_lb_name}-lb"
  description = "Security group for internal load balancer for Traefik"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.internal_lb_name}-lb" })
}

##########################
# Security Group Rules for LB
##########################

# _ -> Internal LB
resource "aws_security_group_rule" "internal_lb_http_incoming" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = concat([data.aws_vpc.traefik.cidr_block], var.internal_lb_incoming_cidr)
  security_group_id = aws_security_group.internal_lb.id
}

# _ -> Internal LB
resource "aws_security_group_rule" "internal_lb_https_incoming" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = concat([data.aws_vpc.traefik.cidr_block], var.internal_lb_incoming_cidr)
  security_group_id = aws_security_group.internal_lb.id
}

# Internal LB -> Traefik Internal Endpoint
resource "aws_security_group_rule" "internal_lb_http_egress" {
  type                     = "egress"
  security_group_id        = aws_security_group.internal_lb.id
  from_port                = 81
  to_port                  = 81
  protocol                 = "tcp"
  source_security_group_id = var.nomad_clients_internal_security_group
}

# Internal LB -> Traefik health check Endpoint
resource "aws_security_group_rule" "internal_lb_health_check_egress" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = var.nomad_clients_internal_security_group
  security_group_id        = aws_security_group.internal_lb.id
}

##########################
# Security Group Rules for Nomad Client
##########################

# Internal LB -> Traefik Internal Endpoint
resource "aws_security_group_rule" "nomad_client_internal_http" {
  type                     = "ingress"
  from_port                = 81
  to_port                  = 81
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.internal_lb.id
  security_group_id        = var.nomad_clients_internal_security_group
}

# Internal LB -> Traefik health check
resource "aws_security_group_rule" "nomad_client_internal_health_check" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.internal_lb.id
  security_group_id        = var.nomad_clients_internal_security_group
}

#####################
# Listeners and target group
#####################

resource "aws_lb_target_group" "internal" {
  name_prefix          = "tfk-i"
  port                 = "81"
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay

  health_check {
    healthy_threshold   = var.healthy_threshold
    matcher             = "200"
    timeout             = var.timeout
    unhealthy_threshold = var.unhealthy_threshold
    interval            = var.interval
    path                = "/ping"
    port                = "8080"
  }

  stickiness {
    enabled = true
    type    = "lb_cookie"
  }

  tags = merge(var.tags, { Name = "${var.internal_lb_name}-traefik-internal" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "internal" {
  autoscaling_group_name = var.internal_nomad_clients_asg
  lb_target_group_arn    = aws_lb_target_group.internal.arn
}

resource "aws_lb_listener" "internal_http" {
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
  certificate_arn   = var.internal_certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.internal.arn
    type             = "forward"
  }
}

#############################
# Defines settings for Traefik internal Reverse Proxy
#############################

# DNS Record for the internal Traefik listener domain.
# Everything else deployed should alias (recommended) or CNAME this domain
resource "aws_route53_record" "internal_dns_record" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = var.traefik_internal_base_domain
  type    = "A"

  alias {
    name                   = aws_lb.internal.dns_name
    zone_id                = aws_lb.internal.zone_id
    evaluate_target_health = false
  }
}
