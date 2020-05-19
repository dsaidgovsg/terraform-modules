locals {
  private_zone_id     = join("", aws_route53_zone.private.*.zone_id)
  fluentd_server_port = 4224
  fluentd_lb_port     = var.fluentd_port
}

##############################
# Define an internal load balancer
##############################

# Internal Load balancer
resource "aws_lb" "fluentd" {
  name            = var.lb_name
  security_groups = [aws_security_group.fluentd_lb.id]
  subnets         = var.lb_subnets
  internal        = true

  idle_timeout               = var.lb_idle_timeout
  enable_deletion_protection = true

  access_logs {
    enabled = var.lb_access_log
    bucket  = var.lb_access_log_bucket
    prefix  = var.lb_access_log_prefix
  }

  tags = merge(var.lb_tags, { Name = var.lb_name })
}

resource "aws_lb_listener" "fluentd_https" {
  load_balancer_arn = aws_lb.fluentd.arn
  port              = local.fluentd_lb_port
  protocol          = "HTTPS"
  ssl_policy        = var.elb_ssl_policy
  certificate_arn   = var.lb_certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.fluentd_server.arn
    type             = "forward"
  }
}

# Security group for the Internal LB
resource "aws_security_group" "fluentd_lb" {
  name        = var.lb_name
  description = "Security group for Internal Load balancer for Fluentd"
  vpc_id      = var.vpc_id

  tags = merge(var.lb_tags, { Name = var.lb_name })
}

resource "aws_security_group_rule" "fluentd_lb_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.fluentd_lb.id
  from_port         = local.fluentd_lb_port
  to_port           = local.fluentd_lb_port
  protocol          = "tcp"
  cidr_blocks       = concat([data.aws_vpc.this.cidr_block], var.lb_incoming_cidr)
}

resource "aws_lb_target_group" "fluentd_server" {
  name                 = "fluentd-server"
  port                 = local.fluentd_server_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = var.fluentd_server_lb_deregistration_delay

  health_check {
    healthy_threshold   = var.lb_healthy_threshold
    unhealthy_threshold = var.lb_unhealthy_threshold
    port                = local.fluentd_server_port
    interval            = var.lb_health_check_interval
  }

  tags = merge(var.lb_tags, { Name = var.tg_group_name })

  lifecycle {
    create_before_destroy = true
  }
}

# Attach target group to the Fluentd servers ASG
resource "aws_autoscaling_attachment" "fluentd_server_internal" {
  autoscaling_group_name = var.cluster_name
  alb_target_group_arn   = aws_lb_target_group.fluentd_server.arn
}

resource "aws_security_group_rule" "fluentd_outgoing" {
  type                     = "egress"
  security_group_id        = aws_security_group.fluentd_lb.id
  from_port                = local.fluentd_server_port
  to_port                  = local.fluentd_server_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lc_security_group.id
}

# Security rules for Fluentd servers to be accessible by the internal LB
resource "aws_security_group_rule" "fluentd_to_lb" {
  type                     = "ingress"
  security_group_id        = aws_security_group.lc_security_group.id
  from_port                = local.fluentd_server_port
  to_port                  = local.fluentd_server_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.fluentd_lb.id
}

# A Record for endpoint to point to Internal Load balancer
resource "aws_route53_record" "fluentd_rpc" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = var.fluentd_api_domain
  type    = "A"

  alias {
    name                   = aws_lb.fluentd.dns_name
    zone_id                = aws_lb.fluentd.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "private_zone_fluentd_rpc" {
  count = var.add_private_route53_zone ? 1 : 0

  zone_id = local.private_zone_id
  name    = var.fluentd_api_domain
  type    = "A"

  alias {
    name                   = aws_lb.fluentd.dns_name
    zone_id                = aws_lb.fluentd.zone_id
    evaluate_target_health = false
  }
}
