resource "vault_aws_auth_backend_role" "nexus" {
  count = var.aws_auth_enabled ? 1 : 0

  backend            = var.aws_auth_path
  role               = var.aws_auth_vault_role
  auth_type          = "ec2"
  bound_iam_role_arn = aws_iam_role.nexus.arn
  policies           = var.aws_auth_policies
  period             = var.aws_auth_period_minutes
}

resource "consul_keys" "aws_auth" {
  count = var.aws_auth_enabled ? 1 : 0

  key {
    path   = "${var.consul_key_prefix}aws-auth/roles/${var.server_type}"
    value  = var.aws_auth_vault_role
    delete = true
  }
}
