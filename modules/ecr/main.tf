data "aws_region" "current" {}

resource "aws_ecr_repository" "default" {
  name = var.name
  tags = var.tags
}

locals {
  service_url = element(split("/", aws_ecr_repository.default.repository_url), 0)
}
