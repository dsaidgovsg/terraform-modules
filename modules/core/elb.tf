##############################
# Define an internal load balancer for API access to Nomad and Consul
##############################

# Internal Load balancer
resource "aws_lb" "internal" {
  name            = "${var.internal_lb_name}"
  security_groups = ["${aws_security_group.internal_lb.id}"]
  subnets         = ["${module.vpc.public_subnets}"]
  internal        = true

  tags = "${var.tags}"
}

# A Record for nomad API endpoint to point to Internal Load balancer
resource "aws_route53_record" "nomad_rpc" {
  zone_id = "${data.aws_route53_zone.default.zone_id}"
  name    = "${var.nomad_api_domain}"
  type    = "A"

  alias {
    name                   = "${aws_lb.internal.dns_name}"
    zone_id                = "${aws_lb.internal.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_lb_listener" "internal_https" {
  load_balancer_arn = "${aws_lb.internal.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "${var.elb_ssl_policy}"
  certificate_arn   = "${var.internal_lb_certificate_arn}"

  # Redirect to a sink target group with zero targets
  default_action {
    target_group_arn = "${aws_lb_target_group.sink.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "sink" {
  name                 = "${var.internal_lb_name}-sink"
  port                 = "80"
  protocol             = "HTTP"
  vpc_id               = "${module.vpc.vpc_id}"
  deregistration_delay = "${var.deregistration_delay}"

  tags = "${var.tags}"
}

# Security group for the Internal LB
resource "aws_security_group" "internal_lb" {
  name        = "${var.internal_lb_name}"
  description = "Security group for Internal Load balancer for Nomad"
  vpc_id      = "${module.vpc.vpc_id}"

  tags = "${merge(var.tags, map("Name", format("%s", var.internal_lb_name)))}"
}

resource "aws_security_group_rule" "internal_http_incoming" {
  type              = "ingress"
  security_group_id = "${aws_security_group.internal_lb.id}"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["${concat(list(module.vpc.vpc_cidr_block), var.internal_lb_incoming_cidr)}"]
}

resource "aws_security_group_rule" "internal_https_incoming" {
  type              = "ingress"
  security_group_id = "${aws_security_group.internal_lb.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["${concat(list(module.vpc.vpc_cidr_block), var.internal_lb_incoming_cidr)}"]
}

##############################
# Nomad Server Access
##############################

resource "aws_lb_listener_rule" "nomad_server" {
  listener_arn = "${aws_lb_listener.internal_https.arn}"
  priority     = "1"

  action {
    target_group_arn = "${aws_lb_target_group.nomad_server.arn}"
    type             = "forward"
  }

  condition {
    field  = "host-header"
    values = ["${var.nomad_api_domain}"]
  }
}

resource "aws_lb_target_group" "nomad_server" {
  name                 = "${var.internal_lb_name}-nomad-server"
  port                 = "4646"
  protocol             = "HTTP"
  vpc_id               = "${module.vpc.vpc_id}"
  deregistration_delay = "${var.deregistration_delay}"

  health_check {
    healthy_threshold   = "5"
    matcher             = "200"
    timeout             = "5"
    unhealthy_threshold = "2"
    path                = "/v1/status/leader"
    port                = "4646"
  }

  tags = "${var.tags}"
}

# Attach target group to the Nomad servers ASG
resource "aws_autoscaling_attachment" "nomad_server_internal" {
  autoscaling_group_name = "${module.nomad_servers.asg_name}"
  alb_target_group_arn   = "${aws_lb_target_group.nomad_server.arn}"
}

resource "aws_security_group_rule" "nomad_api_outgoing" {
  type                     = "egress"
  security_group_id        = "${aws_security_group.internal_lb.id}"
  from_port                = 4646
  to_port                  = 4646
  protocol                 = "tcp"
  source_security_group_id = "${module.nomad_servers.security_group_id}"
}

# Security rules for Nomad servers to be accessible by the internal LB
resource "aws_security_group_rule" "nomad_http" {
  type                     = "ingress"
  security_group_id        = "${module.nomad_servers.security_group_id}"
  from_port                = 4646
  to_port                  = 4646
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.internal_lb.id}"
}

##############################
# Consul Server Access
##############################

resource "aws_lb_listener_rule" "consul_server" {
  listener_arn = "${aws_lb_listener.internal_https.arn}"
  priority     = "2"

  action {
    target_group_arn = "${aws_lb_target_group.consul_servers.arn}"
    type             = "forward"
  }

  condition {
    field  = "host-header"
    values = ["${var.consul_api_domain}"]
  }
}

resource "aws_lb_target_group" "consul_servers" {
  name                 = "${var.internal_lb_name}-consul-server"
  port                 = "8500"
  protocol             = "HTTP"
  vpc_id               = "${module.vpc.vpc_id}"
  deregistration_delay = "${var.deregistration_delay}"

  health_check {
    healthy_threshold   = "5"
    matcher             = "200"
    timeout             = "5"
    unhealthy_threshold = "2"
    path                = "/v1/status/leader"
    port                = "8500"
  }

  tags = "${var.tags}"
}

# Attach target group to the Consul servers ASG
resource "aws_autoscaling_attachment" "consul_server_internal" {
  autoscaling_group_name = "${module.consul_servers.asg_name}"
  alb_target_group_arn   = "${aws_lb_target_group.consul_servers.arn}"
}

resource "aws_security_group_rule" "consul_api_outgoing" {
  type                     = "egress"
  security_group_id        = "${aws_security_group.internal_lb.id}"
  from_port                = 8500
  to_port                  = 8500
  protocol                 = "tcp"
  source_security_group_id = "${module.consul_servers.security_group_id}"
}

# Security rules for Consul servers to be accessible by the internal LB
resource "aws_security_group_rule" "consul_http" {
  type                     = "ingress"
  security_group_id        = "${module.consul_servers.security_group_id}"
  from_port                = 8500
  to_port                  = 8500
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.internal_lb.id}"
}

resource "aws_route53_record" "consul" {
  zone_id = "${data.aws_route53_zone.default.zone_id}"
  name    = "${var.consul_api_domain}"
  type    = "A"

  alias {
    name                   = "${aws_lb.internal.dns_name}"
    zone_id                = "${aws_lb.internal.zone_id}"
    evaluate_target_health = false
  }
}

##############################
# Vault Server Access
##############################

resource "aws_lb_listener_rule" "vault" {
  listener_arn = "${aws_lb_listener.internal_https.arn}"
  priority     = "3"

  action {
    target_group_arn = "${aws_lb_target_group.vault.arn}"
    type             = "forward"
  }

  condition {
    field  = "host-header"
    values = ["${var.vault_api_domain}"]
  }
}

resource "aws_lb_target_group" "vault" {
  name                 = "${var.internal_lb_name}-vault"
  port                 = "8200"
  protocol             = "HTTPS"
  vpc_id               = "${module.vpc.vpc_id}"
  deregistration_delay = "${var.deregistration_delay}"

  health_check {
    healthy_threshold   = "5"
    matcher             = "200"
    timeout             = "5"
    unhealthy_threshold = "2"
    protocol            = "HTTPS"
    path                = "/v1/sys/health?standbyok=true"
    port                = "8200"
  }

  tags = "${var.tags}"
}

# Attach target group to the Vault servers ASG
resource "aws_autoscaling_attachment" "vault_internal" {
  autoscaling_group_name = "${module.vault.asg_name}"
  alb_target_group_arn   = "${aws_lb_target_group.vault.arn}"
}

resource "aws_security_group_rule" "vault_api_outgoing" {
  type                     = "egress"
  security_group_id        = "${aws_security_group.internal_lb.id}"
  from_port                = 8200
  to_port                  = 8200
  protocol                 = "tcp"
  source_security_group_id = "${module.vault.security_group_id}"
}

# Security rules for Vault servers to be accessible by the internal LB
resource "aws_security_group_rule" "vault_https" {
  type                     = "ingress"
  security_group_id        = "${module.vault.security_group_id}"
  from_port                = 8500
  to_port                  = 8500
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.internal_lb.id}"
}

resource "aws_route53_record" "vault" {
  zone_id = "${data.aws_route53_zone.default.zone_id}"
  name    = "${var.vault_api_domain}"
  type    = "A"

  alias {
    name                   = "${aws_lb.internal.dns_name}"
    zone_id                = "${aws_lb.internal.zone_id}"
    evaluate_target_health = false
  }
}
