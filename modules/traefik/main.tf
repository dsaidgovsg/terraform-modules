###################
# Nomad Job to Deploy Traefik
###################

resource "nomad_job" "traefik" {
  depends_on = [
    "aws_lb.external",
    "aws_lb.internal",
    "consul_keys.entrypoints_http",
    "consul_keys.entrypoints_internal",
    "consul_keys.entrypoints_api",
    "consul_keys.consulcatalog_endpoint",
    "consul_keys.consulcatalog_domain",
    "consul_keys.consulcatalog_exposedbydefault",
    "consul_keys.consulcatalog_prefix",
    "consul_keys.api_entrypoint",
    "consul_keys.api_dashboard",
    "consul_keys.ping_entrypoint",
  ]

  jobspec = "${data.template_file.traefik_jobspec.rendered}"
}

data "template_file" "traefik_jobspec" {
  template = "${file("${path.module}/jobs/traefik.nomad")}"

  vars {
    region                   = "${data.aws_region.current.name}"
    az                       = "${jsonencode(data.aws_availability_zones.available.names)}"
    version                  = "${var.traefik_version}"
    consul_port              = "${local.consul_port}"
    traefik_priority         = "${var.traefik_priority}"
    traefik_count            = "${var.traefik_count}"
    traefik_consul_prefix    = "${var.traefik_consul_prefix}"
    additional_docker_config = "${var.additional_docker_config}"
  }
}

###################################################################################################
# Traefik UI
###################################################################################################

resource "aws_route53_record" "traefik_ui" {
  depends_on = ["aws_route53_record.internal_dns_record"]

  zone_id = "${data.aws_route53_zone.default.zone_id}"
  name    = "${var.traefik_ui_domain}"
  type    = "A"

  alias {
    name                   = "${aws_route53_record.internal_dns_record.name}"
    zone_id                = "${data.aws_route53_zone.default.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_lb_target_group" "traefik_ui" {
  name                 = "${var.internal_lb_name}-ui"
  port                 = "8080"
  protocol             = "HTTP"
  vpc_id               = "${var.vpc_id}"
  deregistration_delay = "${var.deregistration_delay}"

  health_check {
    healthy_threshold   = "${var.healthy_threshold}"
    matcher             = "200"
    timeout             = "${var.timeout}"
    unhealthy_threshold = "${var.unhealthy_threshold}"
    interval            = "${var.interval}"
    path                = "/ping"
    port                = "8080"
  }

  stickiness {
    enabled = true
    type    = "lb_cookie"
  }
}

resource "aws_autoscaling_attachment" "traefik_ui" {
  autoscaling_group_name = "${var.internal_nomad_clients_asg}"
  alb_target_group_arn   = "${aws_lb_target_group.traefik_ui.arn}"
}

resource "aws_lb_listener_rule" "traefik_ui" {
  listener_arn = "${aws_lb_listener.internal_https.arn}"
  priority     = "1"

  action {
    target_group_arn = "${aws_lb_target_group.traefik_ui.arn}"
    type             = "forward"
  }

  condition {
    field  = "host-header"
    values = ["${var.traefik_ui_domain}"]
  }
}
