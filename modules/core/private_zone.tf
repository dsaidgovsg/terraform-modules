resource "aws_route53_zone" "private" {
  count = "${var.add_private_zone_route53 ? 1 : 0}"

  name = "${var.route53_zone}."

  vpc {
    vpc_id = "${var.vpc_id}"
  }
}
