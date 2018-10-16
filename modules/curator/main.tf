locals {
  actions = "${file("${path.module}/templates/actions.yml")}"
  config  = "${file("${path.module}/templates/config.yml")}"
}

data "aws_availability_zones" "available" {}

data "aws_region" "current" {}

data "template_file" "jobspec" {
  template = "${file("${path.module}/templates/curator.nomad")}"

  vars {
    region = "${data.aws_region.current.name}"
    az     = "${jsonencode(coalescelist(var.nomad_azs, data.aws_availability_zones.available.names))}"

    job_name   = "${var.job_name}"
    node_class = "${var.nomad_clients_node_class}"

    cron     = "${var.cron}"
    timezone = "${var.timezone}"

    docker_image = "${var.docker_image}"
    docker_tag   = "${var.docker_tag}"
    force_pull   = "${var.force_pull}"

    entrypoint = "${jsonencode(var.entrypoint)}"
    command    = "${var.command}"
    args       = "${jsonencode(var.args)}"

    config  = "${local.config}"
    actions = "${local.actions}"

    config_path  = "${var.config_path}"
    actions_path = "${var.actions_path}"

    consul_prefix         = "${var.consul_key_prefix}curator/"
    elasticsearch_service = "${var.elasticsearch_service}"

    additional_docker_config = "${var.additional_docker_config}"
  }
}

resource "nomad_job" "curator" {
  jobspec = "${data.template_file.jobspec.rendered}"
}
