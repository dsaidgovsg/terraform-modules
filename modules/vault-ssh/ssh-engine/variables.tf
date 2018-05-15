variable "path" {
  description = "Mount Point of the Secrets Engine"
}

variable "description" {
  description = <<EOF
    The type of servers for this SSH engine mount point.
    Name will be used in the human friendly mount description.
EOF
}

# --------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# --------------------------------------------------------------------------------------------------

variable "enabled" {
  description = "Enable deploying this SSH secrets mount"
  default     = true
}

variable "ssh_user" {
  description = "SSH user to allow SSH access"
  default     = "ubuntu"
}

variable "ttl" {
  description = "TTL for the certificate in seconds"
  default     = 300
}

variable "max_ttl" {
  description = "Max TTL for certificate renewal"
  default     = 86400
}

variable "role_name" {
  description = <<EOF
    Name of role to create for this mount point.
EOF

  default = "default"
}
