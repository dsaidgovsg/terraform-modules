# --------------------------------------------------------------------------------------------------
# DEPLOY THE NOMAD CLIENT NODES
# --------------------------------------------------------------------------------------------------

module "nomad_clients" {
  source = "github.com/lawliet89/terraform-aws-nomad//modules/nomad-cluster?ref=aws_autoscaling_attachment"

  cluster_name  = "${var.nomad_cluster_name}-client"
  instance_type = "${var.nomad_client_instance_type}"

  min_size         = "${var.nomad_clients_min}"
  max_size         = "${var.nomad_clients_max}"
  desired_capacity = "${var.nomad_clients_desired}"

  ami_id = "${var.nomad_clients_ami_id}"
  user_data = "${data.template_file.user_data_nomad_client.rendered}"

  vpc_id = "${module.vpc.vpc_id}"
  subnet_ids = "${module.vpc.public_subnets}"

  ssh_key_name = "${var.ssh_key_name}"
  allowed_inbound_cidr_blocks = "${concat(list(module.vpc.vpc_cidr_block), var.nomad_clients_allowed_inbound_cidr_blocks)}"
  allowed_ssh_cidr_blocks = "${var.allowed_ssh_cidr_blocks}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES FOR CONSUL
# To allow our client Nodes to automatically discover the Consul servers, we need to give them the IAM permissions from
# the Consul AWS Module's consul-iam-policies module.
# ---------------------------------------------------------------------------------------------------------------------

module "consul_iam_policies_clients" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-iam-policies?ref=v0.1.1"

  iam_role_id = "${module.nomad_clients.iam_role_id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH CLIENT NODE WHEN IT'S BOOTING
# This script will configure and start Consul and Nomad
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_nomad_client" {
  template = "${file("${path.module}/user_data/user-data-nomad-client.sh")}"

  vars {
    cluster_tag_key   = "${var.cluster_tag_key}"
    cluster_tag_value = "${var.consul_cluster_name}"
  }
}

# Security rules to allow services on Nomad clients to talk to each other
resource "aws_security_group_rule" "nomad_client_services" {
  type = "ingress"
  security_group_id = "${module.nomad_clients.security_group_id}"
  from_port   = 20000
  to_port     = 32000
  protocol    = "tcp"
  cidr_blocks = ["${concat(list(module.vpc.vpc_cidr_block), var.nomad_clients_services_inbound_cidr)}"]
}
