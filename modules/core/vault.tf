# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE VAULT SERVER CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

module "vault" {
    source = "github.com/hashicorp/terraform-aws-vault.git//modules/vault-cluster?ref=v0.5.1"

    cluster_name  = "${var.vault_cluster_name}"
    cluster_size  = "${var.vault_cluster_size}"
    instance_type = "${var.vault_instance_type}"

    ami_id    = "${var.vault_ami_id}"
    user_data = "${coalesce(var.vault_user_data, data.template_file.user_data_vault_cluster.rendered)}"

    root_volume_type = "${var.vault_root_volume_type}"
    root_volume_size = "${var.vault_root_volume_size}"

    vpc_id = "${module.vpc.vpc_id}"
    subnet_ids = "${module.vpc.public_subnets}"

    ssh_key_name = "${var.ssh_key_name}"
    allowed_inbound_security_group_ids = "${var.vault_allowed_inbound_security_group_ids}"
    allowed_inbound_cidr_blocks = "${concat(list(module.vpc.vpc_cidr_block), var.vault_allowed_inbound_cidr_blocks)}"
    allowed_ssh_cidr_blocks = "${var.allowed_ssh_cidr_blocks}"
    associate_public_ip_address = "${var.associate_public_ip_address}"

    enable_s3_backend = "${var.vault_enable_s3_backend}"
    s3_bucket_name = "${var.vault_s3_bucket_name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH IAM POLICIES FOR CONSUL
# To allow our Vault servers to automatically discover the Consul servers, we need to give them the IAM permissions from
# the Consul AWS Module's consul-iam-policies module.
# ---------------------------------------------------------------------------------------------------------------------

module "vault_iam_policies_servers" {
    source = "github.com/hashicorp/terraform-aws-consul.git//modules/consul-iam-policies?ref=v0.3.1"

    iam_role_id = "${module.vault.iam_role_id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# THE USER DATA SCRIPT THAT WILL RUN ON EACH VAULT SERVER WHEN IT'S BOOTING
# This script will configure and start Vault
# ---------------------------------------------------------------------------------------------------------------------

data "template_file" "user_data_vault_cluster" {
    template = "${file("${path.module}/user_data/user-data-vault.sh")}"

    vars {
        aws_region               = "${data.aws_region.current.name}"
        consul_cluster_tag_key   = "${var.cluster_tag_key}"
        consul_cluster_tag_value = "${var.consul_cluster_name}"

        # These paths are set by default by the Packer template. If you have modified them, you
        # will need to change this.
        cert_file = "/opt/vault/tls/vault.crt"
        cert_key = "/opt/vault/tls/vault.key"
        cert_key_encrypted = "/opt/vault/tls/vault.encrypted.key"
        aes_key = "/opt/aes-kms/keys/aes.encrypted.key"
        cli_json = "/opt/aes-kms/keys/cli.json"
        kms_aes_root = "/opt/aes-kms"

        # S3 Variables
        enable_s3_backend = "${var.vault_enable_s3_backend ? "true" : "false"}"
        s3_bucket_name = "${var.vault_s3_bucket_name}"

        consul_prefix = "${var.integration_consul_prefix}"
    }
}

# ---------------------------------------------------------------------------------------------------------------------
# IAM Policy to allow the instances to decrypt the encrypted TLS key baked into the AMI via the Packer template
# Refer to README for more information
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "vault_decrypt" {
    role = "${module.vault.iam_role_id}"
    policy_arn = "${var.vault_tls_key_policy_arn}"
}
