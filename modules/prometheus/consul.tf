locals {
  consul_prefix = "${var.consul_key_prefix}prometheus/"
}

resource "consul_keys" "service_name" {
  key {
    path   = "${local.consul_prefix}service_name"
    value  = var.prometheus_service
    delete = true
  }
}

resource "consul_keys" "client_service" {
  key {
    path   = "${local.consul_prefix}client_service"
    value  = var.prometheus_client_service
    delete = true
  }
}

resource "consul_keys" "db_dir" {
  key {
    path   = "${local.consul_prefix}db_dir"
    value  = var.prometheus_db_dir
    delete = true
  }
}

resource "consul_keys" "port" {
  key {
    path   = "${local.consul_prefix}port"
    value  = var.prometheus_port
    delete = true
  }
}

resource "consul_keys" "data_device_name" {
  key {
    path   = "${local.consul_prefix}data_device_name"
    value  = var.data_device_name
    delete = true
  }
}
