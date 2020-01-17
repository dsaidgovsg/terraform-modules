resource "aws_route53_record" "redirect" {
  count = var.add_route53_record ? 1 : 0

  zone_id = var.route53_zone_id
  name    = var.route53_domain
  type    = "A"

  alias {
    name                   = var.lb_cname
    zone_id                = var.lb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_lb_listener_rule" "redirect" {
  count = var.add_route53_record ? 1 : 0

  listener_arn = var.redirect_listener_arn
  priority     = var.redirect_rule_priority

  action {
    type = "redirect"

    redirect {
      host        = local.service_url
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    field  = "host-header"
    values = [aws_route53_record.redirect.fqdn]
  }
}
