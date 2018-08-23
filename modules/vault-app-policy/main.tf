#################################################
# Policies for apps to access secrets in Vault's KV Store
# Currently, we are unable to do more fine-grained policies in Vault to
# allow app developers to define specific policies only for their apps.
# We need Vault Enterprise integration with Sentinel to write more fine grained
# access control.
#
# For now, we just have to ask administrators to administer app policies.
#
# 1. Remember that Nomad is configured to check that the person submitting the job
#    also has access to the same sets of credentials.
# 2. Remember that Vault policies are based on the most precise path match with
#    deny taking precedence over every other capability.
# 3. Thus, we need to give the app policies to the developers. But, because of point 1 and 2,
#    we also need to give the developers yet another policy to "override"
#    the restrictive app policies.
#################################################

#################################################
# For each application listed in `local.app`, generate two policies that affect the KV path
# at "{var.kv_path}/app/{app}".
# The `app` policy will restrict to only readonly access
# The `dev` policy will allow read/write access.
#
# The policies will have the following naming convention:
# - Read-only: "${var.prefix}_${app}_app"
# - Read-Write: "${var.prefix}_${app}_dev"
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
