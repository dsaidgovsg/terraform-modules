locals {
  # Base path after `consul_key_prefix`
  path = "telegraf/"
}

resource "consul_keys" "core_integration" {
  count = var.core_integration ? 1 : 0

  key {
    path   = "${var.consul_key_prefix}${local.path}README"
    delete = true

    value = <<EOF
This is used for integration with the `core` module.
See https://github.com/GovTechSG/terraform-modules/tree/master/modules/telegraf
EOF
  }
}

module "consul" {
  source = "./server_type"

  server_type = "consul"
  enabled     = var.consul_enabled
  path        = local.path

  output_elastisearch               = var.consul_output_elastisearch
  output_elasticsearch_service_name = var.consul_output_elasticsearch_service_name

  output_prometheus               = var.consul_output_prometheus
  output_prometheus_service_name  = var.consul_output_prometheus_service_name
  output_prometheus_service_port  = var.consul_output_prometheus_service_port
  output_prometheus_service_cidrs = var.consul_output_prometheus_service_cidrs
}

module "nomad_server" {
  source = "./server_type"

  server_type = "nomad_server"
  enabled     = var.nomad_server_enabled
  path        = local.path

  output_elastisearch               = var.nomad_server_output_elastisearch
  output_elasticsearch_service_name = var.nomad_server_output_elasticsearch_service_name

  output_prometheus               = var.nomad_server_output_prometheus
  output_prometheus_service_name  = var.nomad_server_output_prometheus_service_name
  output_prometheus_service_port  = var.nomad_server_output_prometheus_service_port
  output_prometheus_service_cidrs = var.nomad_server_output_prometheus_service_cidrs
}

module "nomad_client" {
  source = "./server_type"

  server_type = "nomad_client"
  enabled     = var.nomad_client_enabled
  path        = local.path

  output_elastisearch               = var.nomad_client_output_elastisearch
  output_elasticsearch_service_name = var.nomad_client_output_elasticsearch_service_name

  output_prometheus               = var.nomad_client_output_prometheus
  output_prometheus_service_name  = var.nomad_client_output_prometheus_service_name
  output_prometheus_service_port  = var.nomad_client_output_prometheus_service_port
  output_prometheus_service_cidrs = var.nomad_client_output_prometheus_service_cidrs
}

module "vault" {
  source = "./server_type"

  server_type = "vault"
  enabled     = var.vault_enabled
  path        = local.path

  output_elastisearch               = var.vault_output_elastisearch
  output_elasticsearch_service_name = var.vault_output_elasticsearch_service_name

  output_prometheus               = var.vault_output_prometheus
  output_prometheus_service_name  = var.vault_output_prometheus_service_name
  output_prometheus_service_port  = var.vault_output_prometheus_service_port
  output_prometheus_service_cidrs = var.vault_output_prometheus_service_cidrs
}
