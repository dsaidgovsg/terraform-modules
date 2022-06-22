# --------------------------------------------------------------------------------------------------
# DEPLOY THE NOMAD CLIENT NODES
# --------------------------------------------------------------------------------------------------

locals {
  nomad_client_cluster_name = var.nomad_client_cluster_name != null ? var.nomad_client_cluster_name : "${var.nomad_cluster_name}-client"
}

module "nomad_clients" {
  source = "../nomad-clients"

  ami_id = var.nomad_clients_ami_id

  vpc_id         = var.vpc_id
  vpc_subnet_ids = var.nomad_client_subnets

  allowed_inbound_cidr_blocks       = var.nomad_clients_allowed_inbound_cidr_blocks
  dynamic_ports_inbound_cidr_blocks = var.nomad_clients_dynamic_ports_inbound_cidr_blocks

  cluster_name  = local.nomad_client_cluster_name
  instance_type = var.nomad_client_instance_type

  clients_min     = var.nomad_clients_min
  clients_desired = var.nomad_clients_desired
  clients_max     = var.nomad_clients_max

  root_volume_type = var.nomad_clients_root_volume_type
  root_volume_size = var.nomad_clients_root_volume_size
  ssh_key_name     = var.ssh_key_name

  associate_public_ip_address = var.associate_public_ip_address
  allowed_ssh_cidr_blocks     = var.allowed_ssh_cidr_blocks

  client_node_class   = var.client_node_class
  cluster_tag_key     = var.cluster_tag_key
  consul_cluster_name = var.consul_cluster_name

  docker_privileged       = var.nomad_clients_docker_privileged
  docker_volumes_mounting = var.nomad_clients_docker_volumes_mounting

  integration_consul_prefix = var.integration_consul_prefix
  integration_service_type  = "nomad_client"

  termination_policies = var.nomad_client_termination_policies

  iam_permissions_boundary = var.iam_permissions_boundary

  additional_security_group_ids = var.nomad_client_allowed_inbound_security_group_ids
}
