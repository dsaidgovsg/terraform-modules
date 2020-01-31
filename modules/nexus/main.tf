data "aws_subnet" "selected" {
  id = var.subnet_id
}

data "aws_vpc" "selected" {
  id = data.aws_subnet.selected.vpc_id
}

resource "aws_instance" "nexus" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.ssh_key_name
  subnet_id     = var.subnet_id

  user_data = data.template_file.user_data.rendered

  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids      = [aws_security_group.nexus.id]
  iam_instance_profile        = aws_iam_instance_profile.nexus.name
  tags                        = merge(var.tags, { Name = var.name })
  volume_tags                 = merge(var.tags, { Name = var.name })

  root_block_device {
    volume_type = "gp2"
    volume_size = var.root_volume_size
  }
}

resource "aws_volume_attachment" "data" {
  device_name = var.data_volume_mount
  volume_id   = var.data_volume_id
  instance_id = aws_instance.nexus.id

  skip_destroy = true
}

data "template_file" "user_data" {
  template = file("${path.module}/files/user_data.sh")

  vars = {
    service_type = var.server_type

    cluster_tag_key   = var.consul_cluster_tag_key
    cluster_tag_value = var.consul_cluster_tag_value
    consul_prefix     = var.consul_key_prefix
  }
}

resource "aws_iam_instance_profile" "nexus" {
  name = var.name
  role = aws_iam_role.nexus.name
}

resource "aws_iam_role" "nexus" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  description        = "IAM Role for Nexus server"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES FOR CONSUL
# To allow our client Nodes to automatically discover the Consul servers, we need to give them the IAM permissions from
# the Consul AWS Module's consul-iam-policies module.
# ---------------------------------------------------------------------------------------------------------------------
module "consul_iam_policies_clients" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-iam-policies?ref=v0.7.4"

  iam_role_id = aws_iam_role.nexus.id
}

# ---------------------------------------------------------------------------------------------------------------------
# SET Security Group
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "nexus" {
  name        = var.name
  description = "Security group for Nexus server"
  vpc_id      = data.aws_subnet.selected.vpc_id

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_security_group_rule" "ssh_ingress" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.allowed_ssh_cidr_blocks
  description = "SSH access to Nexus server"

  security_group_id = aws_security_group.nexus.id
}

resource "aws_security_group_rule" "nexus" {
  type        = "ingress"
  from_port   = var.nexus_port
  to_port     = var.nexus_port
  protocol    = "tcp"
  cidr_blocks = concat(var.additional_cidr_blocks, [data.aws_vpc.selected.cidr_block])
  description = "Access to Nexus server"

  security_group_id = aws_security_group.nexus.id
}

resource "aws_security_group_rule" "egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.nexus.id
}

# ---------------------------------------------------------------------------------------------------------------------
# PERMIT CONSUL SPECIFIC TRAFFIC
# To allow the instance to communicate with other consul agents and participate in the LAN gossip,
# we open up the consul specific protocols and ports for consul traffic
# ---------------------------------------------------------------------------------------------------------------------

module "consul_gossip" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-client-security-group-rules?ref=v0.7.4"

  security_group_id                  = aws_security_group.nexus.id
  allowed_inbound_cidr_blocks        = [data.aws_vpc.selected.cidr_block]
  allowed_inbound_security_group_ids = [var.consul_security_group_id]
}
