#################################################
# IAM Policy to allow Vault servers to perform IAM authentication
# See https://www.vaultproject.io/docs/auth/aws.html
#################################################
# From https://www.vaultproject.io/docs/auth/aws.html#recommended-vault-iam-policy
data "aws_iam_policy_document" "vault_aws_auth" {
  policy_id = "${var.iam_policy_name}"

  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "iam:GetInstanceProfile",
      "iam:GetUser",
      "iam:GetRole",
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "vault_aws_auth" {
  name        = "${var.iam_policy_name}"
  description = "Policy to allow Vault instances to authenticate entities with AWS IAM. See https://www.vaultproject.io/docs/auth/aws.html"
  policy      = "${data.aws_iam_policy_document.vault_aws_auth.json}"
}

resource "aws_iam_role_policy_attachment" "vault_aws_auth" {
  role       = "${var.vault_iam_role_id}"
  policy_arn = "${aws_iam_policy.vault_aws_auth.arn}"
}
