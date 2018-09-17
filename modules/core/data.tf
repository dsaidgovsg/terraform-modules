data "aws_route53_zone" "default" {
  name = "${var.route53_zone}."
}

data "aws_region" "current" {}

data "aws_vpc" "this" {
  id = "${var.vpc_id}"
}
