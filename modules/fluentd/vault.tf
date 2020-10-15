resource "vault_aws_secret_backend_role" "logs" {
  count = var.logs_s3_enabled ? 1 : 0

  credential_type = "iam_user"

  name    = var.log_vault_role
  backend = var.vault_sts_path

  policy_arns = [aws_iam_policy.logs_s3[0].arn]
}

resource "null_resource" "logs_permissions_boundary" {
  depends_on = [vault_aws_secret_backend_role.logs]

  count = var.logs_s3_enabled && var.vault_sts_iam_permissions_boundary != "" ? 1 : 0

  # Permissions boundary workaround
  # https://github.com/terraform-providers/terraform-provider-vault/pull/781#issuecomment-656696212
  # Requires both vault server + host vault CLI to be >= 1.3
  provisioner "local-exec" {
    command = <<EOF
vault write -address="${var.vault_address}" \
"${var.vault_sts_path}/roles/${var.log_vault_role}" \
permissions_boundary_arn="${var.vault_sts_iam_permissions_boundary}"
EOF
  }
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
