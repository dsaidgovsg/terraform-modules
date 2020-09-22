locals {
  allowed_inbound_cidr_blocks = concat(list(data.aws_vpc.selected.cidr_block), var.allowed_inbound_cidr_blocks)
  services_inbound_cidr       = concat(list(data.aws_vpc.selected.cidr_block), var.nomad_clients_services_inbound_cidr)
  user_data                   = coalesce(var.user_data, data.template_file.user_data_nomad_client.rendered)
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

# --------------------------------------------------------------------------------------------------
# DEPLOY THE NOMAD CLIENT NODES
# --------------------------------------------------------------------------------------------------

module "nomad_clients" {
  # Copy of "github.com/hashicorp/terraform-aws-nomad//modules/nomad-cluster?ref=v0.7.0"
  source = "../nomad-cluster"

  asg_name          = var.cluster_name
  cluster_name      = var.cluster_name
  cluster_tag_value = var.cluster_name
  instance_type     = var.instance_type

  min_size         = var.clients_min
  max_size         = var.clients_max
  desired_capacity = var.clients_desired
  spot_price       = var.spot_price

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

  termination_policies = var.termination_policies

  iam_permissions_boundary = var.iam_permissions_boundary
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES FOR CONSUL
# To allow our client Nodes to automatically discover the Consul servers, we need to give them the IAM permissions from
# the Consul AWS Module's consul-iam-policies module.
# ---------------------------------------------------------------------------------------------------------------------

module "consul_iam_policies_clients" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-iam-policies?ref=v0.8.3"

  iam_role_id = module.nomad_clients.iam_role_id
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH CLIENT NODE WHEN IT'S BOOTING
# This script will configure and start Consul and Nomad
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_nomad_client" {
  template = file("${path.module}/user_data.sh")

  vars = {
    client_node_class       = var.client_node_class
    cluster_tag_key         = var.cluster_tag_key
    cluster_tag_value       = var.consul_cluster_name
    docker_privileged       = var.docker_privileged ? "--docker-privileged" : ""
    docker_volumes_mounting = var.docker_volumes_mounting ? "--docker-volumes-mounting" : ""
    consul_prefix           = var.integration_consul_prefix
    service_type            = coalesce(var.integration_service_type, var.cluster_name)
  }
}

# Security rules to allow services on Nomad clients to talk to each other
resource "aws_security_group_rule" "nomad_client_services_tcp" {
  type              = "ingress"
  security_group_id = module.nomad_clients.security_group_id
  from_port         = 20000
  to_port           = 32000
  protocol          = "tcp"
  cidr_blocks       = local.services_inbound_cidr
}

resource "aws_security_group_rule" "nomad_client_services_udp" {
  type              = "ingress"
  security_group_id = module.nomad_clients.security_group_id
  from_port         = 20000
  to_port           = 32000
  protocol          = "udp"
  cidr_blocks       = local.services_inbound_cidr
}
