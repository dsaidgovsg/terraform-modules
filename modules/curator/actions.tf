module "consul" {
  source = "./action"

  key               = "consul"
  disable           = "${var.consul_disable}"
  age               = "${var.consul_age}"
  prefix            = "${var.consul_prefix}"
  consul_key_prefix = "${var.consul_key_prefix}"
}

module "consul_template" {
  source = "./action"

  key               = "consul_template"
  disable           = "${var.consul_template_disable}"
  age               = "${var.consul_template_age}"
  prefix            = "${var.consul_template_prefix}"
  consul_key_prefix = "${var.consul_key_prefix}"
}

module "nomad" {
  source = "./action"

  key               = "nomad"
  disable           = "${var.nomad_disable}"
  age               = "${var.nomad_age}"
  prefix            = "${var.nomad_prefix}"
  consul_key_prefix = "${var.consul_key_prefix}"
}

module "vault" {
  source = "./action"

  key               = "vault"
  disable           = "${var.vault_disable}"
  age               = "${var.vault_age}"
  prefix            = "${var.vault_prefix}"
  consul_key_prefix = "${var.consul_key_prefix}"
}

module "docker" {
  source = "./action"

  key               = "docker"
  disable           = "${var.docker_disable}"
  age               = "${var.docker_age}"
  prefix            = "${var.docker_prefix}"
  consul_key_prefix = "${var.consul_key_prefix}"
}

module "cron" {
  source = "./action"

  key               = "cron"
  disable           = "${var.cron_disable}"
  age               = "${var.cron_age}"
  prefix            = "${var.cron_prefix}"
  consul_key_prefix = "${var.consul_key_prefix}"
}

module "td_agent" {
  source = "./action"

  key               = "td_agent"
  disable           = "${var.td_agent_disable}"
  age               = "${var.td_agent_age}"
  prefix            = "${var.td_agent_prefix}"
  consul_key_prefix = "${var.consul_key_prefix}"
}

module "telegraf" {
  source = "./action"

  key               = "telegraf"
  disable           = "${var.telegraf_disable}"
  age               = "${var.telegraf_age}"
  prefix            = "${var.telegraf_prefix}"
  consul_key_prefix = "${var.consul_key_prefix}"
}

module "sshd" {
  source = "./action"

  key               = "sshd"
  disable           = "${var.sshd_disable}"
  age               = "${var.sshd_age}"
  prefix            = "${var.sshd_prefix}"
  consul_key_prefix = "${var.consul_key_prefix}"
}

module "sudo" {
  source = "./action"

  key               = "sudo"
  disable           = "${var.sudo_disable}"
  age               = "${var.sudo_age}"
  prefix            = "${var.sudo_prefix}"
  consul_key_prefix = "${var.consul_key_prefix}"
}
