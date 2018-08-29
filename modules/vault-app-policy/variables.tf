variable "prefix" {
  description = "Prefix to prepend to the policy name"
  default     = ""
}

variable "kv_path" {
  description = "Vault Key/value prefix path to the secrets"
}

variable "app" {
  description = "App name to set policy"
}
