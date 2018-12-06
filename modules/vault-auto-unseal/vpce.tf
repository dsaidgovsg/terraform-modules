# VPC Endpoint for KMS
resource "aws_vpc_endpoint" "kms" {
  count = "${var.enable_kms_vpce ? 1 : 0}"

  vpc_id             = "${var.vpc_id}"
  vpc_endpoint_type  = "${data.aws_vpc_endpoint_service.kms.service_type}"
  service_name       = "${data.aws_vpc_endpoint_service.kms.service_name}"
  auto_accept        = true
  security_group_ids = ["${aws_security_group.kms_vpce.id}"]
}

# Filter subnets that the KMS endpoint is available for
# As of now, ap-southeast-1c does not support this
# First, gather information about subnets
data "aws_subnet" "kms_vpce_subnet" {
  count = "${var.vpce_subnets_count}"
  id    = "${element(var.vpce_subnets, count.index)}"
}

# Second, filter
locals {
  kms_vpce_subnets = "${matchkeys(data.aws_subnet.kms_vpce_subnet.*.id, data.aws_subnet.kms_vpce_subnet.*.availability_zone, data.aws_vpc_endpoint_service.kms.availability_zones)}"
}

resource "aws_vpc_endpoint_subnet_association" "kms" {
  count           = "${var.enable_kms_vpce ? length(local.kms_vpce_subnets): 0}"
  subnet_id       = "${element(local.kms_vpce_subnets, count.index)}"
  vpc_endpoint_id = "${aws_vpc_endpoint.kms.id}"
}

resource "aws_security_group" "kms_vpce" {
  name                   = "${var.vpce_sg_name}"
  description            = "Rules for accessing the KMS VPC endpoint"
  vpc_id                 = "${var.vpc_id}"
  revoke_rules_on_delete = true
  tags                   = "${merge(var.tags, map("Name", "${var.vpce_sg_name}"))}"
}

resource "aws_security_group_rule" "kms_vpce_ingress" {
  security_group_id = "${aws_security_group.kms_vpce.id}"
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["${matchkeys(data.aws_subnet.kms_vpce_subnet.*.cidr_block, data.aws_subnet.kms_vpce_subnet.*.availability_zone, data.aws_vpc_endpoint_service.kms.availability_zones)}"]
}
