locals {
  private_zone_id = join("", aws_route53_zone.private.*.zone_id)
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

  idle_timeout               = var.elb_idle_timeout
  enable_deletion_protection = true

  access_logs {
    enabled = var.lb_access_log
    bucket  = var.lb_access_log_bucket
    prefix  = var.lb_access_log_prefix
  }

  tags = merge(var.tags, { Name = var.lb_name })
}

resource "aws_lb_listener" "fluentd_tcp" {
  load_balancer_arn = aws_lb.fluentd.arn
  port              = "80"
  protocol          = "TCP"

  # Redirect to HTTPS
  default_action {
    arget_group_arn = aws_lb_target_group.fluentd_server.arn
    type            = "forward"
  }
}

// resource "aws_lb_target_group" "fluentd_sink" {
//   name_prefix          = "fluentd-sink"
//   port                 = "80"
//   protocol             = "HTTP"
//   vpc_id               = var.vpc_id
//   deregistration_delay = "30" # It doesn't matter

//   tags = merge(var.tags, { Name = `${var.lb_name}-sink` })

//   lifecycle {
//     create_before_destroy = true
//   }
// }

# Security group for the Internal LB
resource "aws_security_group" "fluentd_lb" {
  name        = var.lb_name
  description = "Security group for Internal Load balancer for Fluentd"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, { Name = var.lb_name })
}

resource "aws_security_group_rule" "fluentd_lb_incoming" {
  type              = "ingress"
  security_group_id = aws_security_group.fluentd_lb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = concat([data.aws_vpc.this.cidr_block], var.fluentd_lb_incoming_cidr)
}

resource "aws_lb_target_group" "fluentd_server" {
  name_prefix          = "fluentd_server"
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

  tags = merge(var.tags, { Name = `${var.b_name}-fluentd-server` })

  lifecycle {
    create_before_destroy = true
  }
}

# Attach target group to the Fluentd servers ASG
resource "aws_autoscaling_attachment" "fluentd_server_internal" {
  autoscaling_group_name = module.fluentd.asg_name
  alb_target_group_arn   = aws_lb_target_group.fluentd_server.arn
}

resource "aws_security_group_rule" "fluentd_outgoing" {
  type                     = "egress"
  security_group_id        = aws_security_group.internal_lb.id
  from_port                = local.fluentd_server_port
  to_port                  = local.fluentd_server_port
  protocol                 = "tcp"
  source_security_group_id = module.fluentd.security_group_id
}

# Security rules for Fluentd servers to be accessible by the internal LB
resource "aws_security_group_rule" "fluentd_to_lb" {
  type                     = "ingress"
  security_group_id        = module.fluentd.security_group_id
  from_port                = local.fluentd_server_port
  to_port                  = local.fluentd_server_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.internal_lb.id
}

# A Record for nomad API endpoint to point to Internal Load balancer
// resource "aws_route53_record" "nomad_rpc" {
//   zone_id = data.aws_route53_zone.default.zone_id
//   name    = var.nomad_api_domain
//   type    = "A"

//   alias {
//     name                   = aws_lb.internal.dns_name
//     zone_id                = aws_lb.internal.zone_id
//     evaluate_target_health = false
//   }
// }

// resource "aws_route53_record" "private_zone_nomad_rpc" {
//   count = var.add_private_route53_zone ? 1 : 0

//   zone_id = local.private_zone_id
//   name    = var.nomad_api_domain
//   type    = "A"

//   alias {
//     name                   = aws_lb.internal.dns_name
//     zone_id                = aws_lb.internal.zone_id
//     evaluate_target_health = false
//   }
// }
