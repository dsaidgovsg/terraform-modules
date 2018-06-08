resource "consul_key_prefix" "core_integration" {
  count       = "${var.core_integration ? 1 : 0}"
  path_prefix = "${var.consul_key_prefix}telegraf/"

  subkeys {
    "enabled" = "yes"
    "README"  = "This is used for integration with the `core` module. See https://github.com/GovTechSG/terraform-modules/tree/master/modules/telegraf"
  }
}
