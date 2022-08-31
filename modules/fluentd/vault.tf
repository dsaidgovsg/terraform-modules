resource "vault_aws_secret_backend_role" "logs" {
  count = var.logs_s3_enabled ? 1 : 0

  credential_type = "iam_user"

  name    = var.log_vault_role
  backend = var.vault_sts_path

  policy_arns = [aws_iam_policy.logs_s3[0].arn]
  # When var.vault_sts_iam_permissions_boundary is null, this optional property is not set
  permissions_boundary_arn = var.vault_sts_iam_permissions_boundary
}

resource "vault_policy" "logs" {
  count = var.logs_s3_enabled ? 1 : 0

  name = var.log_vault_policy

  policy = <<EOF
path "${local.aws_creds_path}" {
  capabilities = ["read"]
}
EOF
}
