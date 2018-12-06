data "aws_iam_policy_document" "vault_unseal" {
  statement {
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

resource "aws_kms_key" "vault_unseal" {
  description             = "Vault KMS Auto-unseal key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = "${data.aws_iam_policy_document.vault_unseal.json}"
  tags                    = "${var.tags}"
}

resource "aws_kms_alias" "vault_unseal" {
  name          = "${var.kms_key_alias}"
  target_key_id = "${aws_kms_key.vault_unseal.key_id}"
}
