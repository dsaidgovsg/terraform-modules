# --------------------------------------------------------------------------------------------------
# DEPLOY THE NOMAD SERVER NODES
# --------------------------------------------------------------------------------------------------

locals {
  nomad_server_http_port    = 4646
  nomad_server_user_data    = coalesce(var.nomad_servers_user_data, data.template_file.user_data_nomad_server.rendered)
  nomad_server_cluster_name = var.nomad_server_cluster_name != null ? var.nomad_server_cluster_name : "${var.nomad_cluster_name}-server"
}

module "nomad_servers" {
  source = "../nomad-cluster"

  asg_name          = local.nomad_server_cluster_name
  cluster_name      = local.nomad_server_cluster_name
  cluster_tag_value = local.nomad_server_cluster_name
  instance_type     = var.nomad_server_instance_type

  # You should typically use a fixed size of 3 or 5 for your Nomad server cluster
  min_size         = var.nomad_servers_num
  max_size         = var.nomad_servers_num
  desired_capacity = var.nomad_servers_num
  spot_price       = ""

  ami_id    = var.nomad_servers_ami_id
  user_data = local.nomad_server_user_data

  root_volume_type = var.nomad_servers_root_volume_type
  root_volume_size = var.nomad_servers_root_volume_size

  vpc_id     = var.vpc_id
  subnet_ids = var.nomad_server_subnets
  http_port  = local.nomad_server_http_port

  ssh_key_name                = var.ssh_key_name
  allowed_inbound_cidr_blocks = concat([data.aws_vpc.this.cidr_block], var.nomad_servers_allowed_inbound_cidr_blocks)
  allowed_ssh_cidr_blocks     = var.allowed_ssh_cidr_blocks
  associate_public_ip_address = var.associate_public_ip_address

  health_check_type    = "ELB"
  termination_policies = var.nomad_server_termination_policies

  iam_permissions_boundary = var.iam_permissions_boundary

  security_groups = var.nomad_server_allowed_inbound_security_group_ids
}

# --------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES FOR CONSUL
# To allow our server Nodes to automatically discover the Consul servers, we need to give them the
# IAM permissions from
# the Consul AWS Module's consul-iam-policies module.
# --------------------------------------------------------------------------------------------------

module "consul_iam_policies_servers" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-iam-policies?ref=v0.8.3"

  iam_role_id = module.nomad_servers.iam_role_id
}

# --------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH NOMAD SERVER NODE WHEN IT'S BOOTING
# This script will configure and start Nomad
# --------------------------------------------------------------------------------------------------

data "template_file" "user_data_nomad_server" {
  template = file("${path.module}/user_data/user-data-nomad-server.sh")

  vars = {
    num_servers       = var.nomad_servers_num
    cluster_tag_key   = var.cluster_tag_key
    cluster_tag_value = var.consul_cluster_name
    consul_prefix     = var.integration_consul_prefix
  }
}
