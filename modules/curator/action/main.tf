resource "consul_key_prefix" "action" {
  path_prefix = "${var.consul_key_prefix}curator/${var.key}/"

  subkeys = {
    disable = var.disable
    age     = var.age
    prefix  = var.prefix
    suffix  = var.suffix
  }
}

variable "key" {
  description = "Name fo the action"
}

variable "disable" {
  description = "Disable this action"
  default     = false
}

variable "age" {
  description = "Age in days for indices to be cleared"
  default     = 90
}

variable "prefix" {
  description = "Index prefix to filter"
  default     = ""
}

variable "suffix" {
  description = "Index suffix to filter"
  default     = ""
}

variable "consul_key_prefix" {
  description = <<EOF
        Path prefix to the key in Consul to set for the `core` module to know that this module has
        been applied. If you change this, you have to update the
        `integration_consul_prefix` variable in the core module as well.
EOF

  default = "terraform/"
}
