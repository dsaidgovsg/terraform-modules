#################################################
# Policies for apps to access secrets in Vault's KV Store
# Generate two policies that affect the KV path at "${var.kv_path}/app/${var.app}"
# The `app` policy will restrict to only readonly access
# The `dev` policy will allow read/write access.
#
# The policies will have the following naming convention:
# - Read-only  (app): "${var.prefix}_${var.app}_app"
# - Read-Write (dev): "${var.prefix}_${var.app}_dev"
#
# Be sure not to use same app name across all your application services
#################################################

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
  app_policy_name = "${var.prefix}_${var.app}_app"
  dev_policy_name = "${var.prefix}_${var.app}_dev"
}
