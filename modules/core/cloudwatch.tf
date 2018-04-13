#############################################
# Cloudwatch Metrics and Logging Related
#############################################

# Attach policies to various IAM roles to allow Cloudwatch agent access to Cloudwatch
locals {
    aws_cloudwatch_agent_policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy"
}

resource "aws_iam_role_policy_attachment" "consul_cloudwatch_agent" {
    role = "${module.consul_servers.iam_role_id}"
    policy_arn = "${local.aws_cloudwatch_agent_policy_arn}"
}

resource "aws_iam_role_policy_attachment" "nomad_server_cloudwatch_agent" {
    role = "${module.nomad_servers.iam_role_id}"
    policy_arn = "${local.aws_cloudwatch_agent_policy_arn}"
}

resource "aws_iam_role_policy_attachment" "nomad_client_cloudwatch_agent" {
    role = "${module.nomad_clients.iam_role_id}"
    policy_arn = "${local.aws_cloudwatch_agent_policy_arn}"
}

resource "aws_iam_role_policy_attachment" "vault_cloudwatch_agent" {
    role = "${module.vault.iam_role_id}"
    policy_arn = "${local.aws_cloudwatch_agent_policy_arn}"
}
