# Define the DNS record to point to the external LB
resource "aws_route53_record" "redirect" {
  count = var.use_redirect ? 1 : 0

  zone_id = var.redirect_route53_zone_id
  name    = var.redirect_domain
  type    = "A"

  alias {
    name                   = var.lb_cname
    zone_id                = var.lb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_lb_listener_rule" "redirect" {
  count = var.use_redirect ? 1 : 0

  listener_arn = var.redirect_listener_arn
  priority     = var.redirect_rule_priority

  action {
    type = "redirect"

    redirect {
      host        = var.es_endpoint
      path        = "/_plugin/kibana/#{path}"
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = [aws_route53_record.redirect[0].fqdn]
    }
  }
}
