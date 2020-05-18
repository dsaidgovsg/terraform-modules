data "aws_route53_zone" "default" {
  name = "${var.route53_zone}."
}

data "aws_vpc" "this" {
  id = var.vpc_id
}

data "aws_region" "current" {}

data "aws_subnet" "internal_lb_subnets" {
  count = length(var.lb_subnets)
  id    = var.lb_subnets[count.index]
}

resource "aws_route53_zone" "private" {
  count = var.add_private_route53_zone ? 1 : 0
  name  = "${var.route53_zone}."

  vpc {
    vpc_id = var.vpc_id
  }
}
