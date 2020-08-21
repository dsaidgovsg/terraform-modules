locals {
  allowed_inbound_cidr_blocks = concat(list(data.aws_vpc.selected.cidr_block), var.allowed_inbound_cidr_blocks)
  services_inbound_cidr       = concat(list(data.aws_vpc.selected.cidr_block), var.services_inbound_cidr)
  user_data                   = coalesce(var.user_data, data.template_file.user_data_fluentd_server.rendered)
  security_group_id           = aws_security_group.lc_security_group.id
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

module "fluentd_new" {
  source = "./modules/fluentd_base"

  asg_name          = var.cluster_name
  cluster_name      = var.cluster_name
  cluster_tag_value = var.cluster_name
  instance_type     = var.instance_type

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_size

  ami_id    = var.ami_id
  user_data = local.user_data

  root_volume_type = var.root_volume_type
  root_volume_size = var.root_volume_size

  vpc_id     = var.vpc_id
  subnet_ids = var.vpc_subnet_ids

  ssh_key_name                = var.ssh_key_name
  allowed_inbound_cidr_blocks = local.allowed_inbound_cidr_blocks
  allowed_ssh_cidr_blocks     = var.allowed_ssh_cidr_blocks
  associate_public_ip_address = var.associate_public_ip_address
  security_group_id           = local.security_group_id

  termination_policies = var.termination_policies
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN WHEN BOOTING
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_fluentd_server" {
  template = file("${path.module}/user_data.sh")
  vars = {
    service_type = var.cluster_name
  }
}

resource "aws_security_group" "lc_security_group" {
  name_prefix = var.cluster_name
  description = "Security group for the ${var.cluster_name} launch configuration"
  vpc_id      = var.vpc_id

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }
}

# Security rules to allow Fluentd servers to talk to each other
resource "aws_security_group_rule" "fluentd_server_services" {
  type              = "ingress"
  security_group_id = local.security_group_id
  from_port         = var.fluentd_port
  to_port           = var.fluentd_port
  protocol          = "tcp"
  cidr_blocks       = local.services_inbound_cidr
}

# Attach IAM policy
resource "aws_iam_role_policy_attachment" "fluentd_server_iam" {
  role       = module.fluentd_new.iam_role_id
  policy_arn = var.s3_logging_arn
}
