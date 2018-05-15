# --------------------------------------------------------------------------------------------------
# SETUP VPC WHERE ALL OF THE INFRA WILL BE CONTAINED
# --------------------------------------------------------------------------------------------------

module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc?ref=v1.23.0"

  name = "${var.vpc_name}"
  cidr = "${var.vpc_cidr}"

  azs              = "${var.vpc_azs}"
  public_subnets   = "${var.vpc_public_subnets_cidr}"
  private_subnets  = "${var.vpc_private_subnets_cidr}"
  database_subnets = "${var.vpc_database_subnets_cidr}"

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true

  tags = "${var.tags}"
}
