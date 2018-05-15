data "aws_route53_zone" "default" {
  name = "${var.route53_zone}."
}

data "aws_acm_certificate" "internal_lb_certificate" {
  domain   = "${var.internal_lb_certificate}"
  statuses = ["ISSUED"]
}

data "aws_region" "current" {
  current = true
}
