locals {
  aws_creds_path = var.logs_s3_enabled ? "${var.vault_sts_path}/creds/${vault_aws_secret_backend_role.logs.*.name[0]}" : ""
}

resource "vault_aws_secret_backend_role" "logs" {
  count = var.logs_s3_enabled ? 1 : 0

  name            = var.log_vault_role
  backend         = var.vault_sts_path
  credential_type = "iam_user"

  policy_arns = aws_iam_policy.logs_s3.*.arn
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
