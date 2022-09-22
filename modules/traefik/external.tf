###################################################################################################
# Traefik External Reverse Proxy
###################################################################################################

resource "aws_lb" "external" {
  name            = var.external_lb_name
  security_groups = [aws_security_group.external_lb.id]
  subnets         = var.lb_external_subnets

  access_logs {
    enabled = var.lb_external_access_log
    bucket  = var.lb_external_access_log_bucket
    prefix  = var.lb_external_access_log_prefix
  }

  drop_invalid_header_fields = var.external_drop_invalid_header_fields

  tags = merge(var.tags, { Name = var.external_lb_name })
}

resource "aws_security_group" "external_lb" {
  name        = "${var.external_lb_name}-lb"
  description = "Security group for external load balancer for Traefik"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = "${var.external_lb_name}-lb" })
}

##########################
# Security Group Rules for LB
##########################

# _ -> External LB
resource "aws_security_group_rule" "external_lb_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.external_lb_incoming_cidr
  security_group_id = aws_security_group.external_lb.id
}

# _ -> External LB
resource "aws_security_group_rule" "external_lb_https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.external_lb_incoming_cidr
  security_group_id = aws_security_group.external_lb.id
}

# External LB -> Traefik External endpoint
resource "aws_security_group_rule" "external_lb_http_egress" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = var.nomad_clients_external_security_group
  security_group_id        = aws_security_group.external_lb.id
}

# External LB -> Traefik health check
resource "aws_security_group_rule" "external_lb_health_check_egress" {
  type                     = "egress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = var.nomad_clients_external_security_group
  security_group_id        = aws_security_group.external_lb.id
}

##########################
# Security Group Rules for Nomad Clients
##########################

# External LB -> Traefik External Endpoint
resource "aws_security_group_rule" "nomad_external_http_ingress" {
  type                     = "ingress"
  security_group_id        = var.nomad_clients_external_security_group
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.external_lb.id
}

# External LB -> Traefik health check
resource "aws_security_group_rule" "nomad_external_health_check_ingress" {
  type                     = "ingress"
  security_group_id        = var.nomad_clients_external_security_group
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.external_lb.id
}

#####################
# Listeners and target group
#####################

resource "aws_lb_listener" "http_external" {
  count = var.external_enable_http ? 1 : 0

  load_balancer_arn = aws_lb.external.arn
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

resource "aws_lb_listener" "https_external" {
  load_balancer_arn = aws_lb.external.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.elb_ssl_policy
  certificate_arn   = var.external_certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.external.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "external" {
  name_prefix          = "tfk"
  port                 = "80"
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

  tags = merge(var.tags, { Name = "${var.external_lb_name}-traefik" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "external" {
  autoscaling_group_name = var.external_nomad_clients_asg
  alb_target_group_arn   = aws_lb_target_group.external.arn
}

#############################
# Defines settings for Traefik Reverse Proxy
#############################

# DNS Record for the external Traefik listener domain.
# Everything else deployed should alias (recommended) or CNAME this domain
resource "aws_route53_record" "external_dns_record" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = var.traefik_external_route53_domain
  type    = "A"

  alias {
    name                   = aws_lb.external.dns_name
    zone_id                = aws_lb.external.zone_id
    evaluate_target_health = false
  }
}
