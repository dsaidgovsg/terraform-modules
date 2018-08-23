data "template_file" "app_readonly" {
  template = "${file("${path.module}/templates/kv_app.hcl")}"

  vars {
    kv_path = "${var.kv_path}/app/${var.app}"
  }
}

resource "vault_policy" "app_readonly" {
  name   = "${local.app_policy_name}"
  policy = "${data.template_file.app_readonly.rendered}"
}

data "template_file" "app_read_write" {
  template = "${file("${path.module}/templates/kv_dev.hcl")}"

  vars {
    kv_path = "${var.kv_path}/app/${var.app}"
  }
}

resource "vault_policy" "app_read_write" {
  name   = "${local.dev_policy_name}"
  policy = "${data.template_file.app_read_write.rendered}"
}

locals {
  prefix          = "${var.prefix == "" ? "" : format("%s%s", var.prefix, "_")}"
  app_policy_name = "${local.prefix}${var.app}_app"
  dev_policy_name = "${local.prefix}${var.app}_dev"
}
