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
  name               = var.lb_name
  subnets            = var.lb_subnets
  internal           = true
  load_balancer_type = "network"

  idle_timeout               = var.lb_idle_timeout
  enable_deletion_protection = true

  access_logs {
    enabled = var.lb_access_log
    bucket  = var.lb_access_log_bucket
    prefix  = var.lb_access_log_prefix
  }

  tags = merge(var.lb_tags, { Name = var.lb_name })
}

resource "aws_lb_listener" "fluentd_tcp" {
  load_balancer_arn = aws_lb.fluentd.arn
  port              = local.fluentd_lb_port
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.fluentd_server.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "fluentd_server" {
  name                 = "fluentd-server-5"
  port                 = local.fluentd_server_port
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  deregistration_delay = var.fluentd_server_lb_deregistration_delay

  health_check {
    healthy_threshold   = var.lb_healthy_threshold
    unhealthy_threshold = var.lb_unhealthy_threshold
    port                = local.fluentd_server_port
    interval            = var.lb_health_check_interval
  }

  tags = merge(var.lb_tags, { Name = var.tg_group_name })

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Attach target group to the Fluentd servers ASG
resource "aws_autoscaling_attachment" "fluentd_server_internal" {
  autoscaling_group_name = var.cluster_name
  alb_target_group_arn   = aws_lb_target_group.fluentd_server.arn
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
