data "aws_route53_zone" "default" {
  name = "${var.route53_zone}."
}

data "aws_region" "current" {}

data "aws_vpc" "this" {
  id = var.vpc_id
}

data "aws_subnet" "internal_lb_subnets" {
  count = length(var.lb_subnets)

  id = var.lb_subnets[count.index]
}
