data "aws_route53_zone" "default" {
  name = "${var.route53_zone}."
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}
