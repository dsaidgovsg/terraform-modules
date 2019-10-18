module "curator" {
  source = "../curator/action"

  key               = "prometheus"
  disable           = var.curator_enable ? false : true
  age               = var.curator_age
  prefix            = var.curator_prefix
  consul_key_prefix = var.consul_key_prefix
}
