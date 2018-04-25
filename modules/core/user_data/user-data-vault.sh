#!/usr/bin/env bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
# run-consul script to configure and start Consul in client mode and then the run-vault script to configure and start
# Vault in server mode. Note that this script assumes it's running in an AMI built from the Packer template in
# examples/vault-consul-ami/vault-consul.json.

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# See https://github.com/ansible/ansible/issues/21562
AWS_DEFAULT_REGION="${aws_region}" \
    HOME=/root \
    ansible-playbook \
    -i "localhost," \
    -c "local" \
    -t "decrypt" \
    -e "cli_json=${cli_json}" \
    -e "key_output=${aes_key}" \
    -e "encrypted_vault_file=${cert_key_encrypted}" \
    -e "decrypted_vault_file=${cert_key}" \
    "${kms_aes_root}/vault.yml"

# The Packer template puts the TLS certs in these file paths
readonly VAULT_TLS_CERT_FILE="${cert_file}"
readonly VAULT_TLS_KEY_FILE="${cert_key}"

# The variables below are filled in via Terraform interpolation
/opt/consul/bin/run-consul --client \
    --cluster-tag-key "${consul_cluster_tag_key}" \
    --cluster-tag-value "${consul_cluster_tag_value}"

if [ "${enable_s3_backend}" = "true" ] ; then
    /opt/vault/bin/run-vault \
        --tls-cert-file "$VAULT_TLS_CERT_FILE"  \
        --tls-key-file "$VAULT_TLS_KEY_FILE" \
        --enable-s3-backend \
        --s3-bucket "${s3_bucket_name}" \
        --s3-bucket-region "${aws_region}"

else
    /opt/vault/bin/run-vault \
        --tls-cert-file "$VAULT_TLS_CERT_FILE"  \
        --tls-key-file "$VAULT_TLS_KEY_FILE"
fi

/opt/vault-ssh \
    --consul-prefix "${consul_prefix}" \
    --type "vault"
