data "aws_caller_identity" "current" {}

data "aws_vpc_endpoint_service" "kms" {
  service = "kms"
}
