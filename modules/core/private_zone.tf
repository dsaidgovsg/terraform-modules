resource "aws_route53_zone" "private" {
  count = "${var.use_private_zone ? 1 : 0}"

  name = "${var.route53_zone}."

  vpc {
    vpc_id = "${var.vpc_id}"
  }
}
