#!/usr/bin/env bash
set -euo pipefail

# Note: This script works assumes that the non-configurable defaults setup by the Ansible roles
# and the `core` and `nomad-vault-integration` modules are not changed. Otherwise, it will fail to
# find the right values and will not work.

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

readonly EC2_INSTANCE_METADATA_URL="http://169.254.169.254/latest/meta-data"
readonly EC2_INSTANCE_DYNAMIC_DATA_URL="http://169.254.169.254/latest/dynamic"

readonly MAX_RETRIES=30
readonly SLEEP_BETWEEN_RETRIES_SEC=10

function print_usage {
  echo
  echo "Usage: configure [OPTIONS]"
  echo
  echo "This script is used to configure Nomad for Vault integration on an AWS server."
  echo
  echo "Options:"
  echo
  echo -e "  --server\t\tIf set, configure in server mode. Optional. Exactly one of --server or --client must be set."
  echo -e "  --client\t\tIf set, configure in client mode. Optional. Exactly one of --server or --client must be set."
  echo -e "  --config-dir\t\tThe path to write the config files to. Optional. Default is the absolute path of '../config', relative to this script."
  echo -e "  --vault-address\t\tAddress of Vault server. Optional. Defaults to \"https://vault.service.consul:8200\""
  echo -e "  --consul-prefix\t\tPath prefix in Consul KV store to query for integration status. Optional. Defaults to terraform/"
  echo -e "  --consul-template-config\t\tPath to directory of configuration files for Consul Template. Optional. Defaults to `/opt/consul-template/config`"
  echo -e "  --docker-auth\t\tPath to store Docker authentication information. Optional. Default is the absolute path of '../docker.json', relative to this script."
  echo -e "  --cert-path\t\tPath to store certificates for nomad TLS. Optional. Default is the absolute path of '../certs', relative to this script."
  echo -e "  --user\t\tThe user to run Nomad as. Optional. Default is to use the owner of --config-dir."
  echo
  echo "Example:"
  echo
  echo "  configure --server"
}

function log {
  local readonly level="$1"
  local readonly message="$2"
  local readonly timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  >&2 echo -e "${timestamp} [${level}] [$SCRIPT_NAME] ${message}"
}

function log_info {
  local readonly message="$1"
  log "INFO" "${message}"
}

function log_warn {
  local readonly message="$1"
  log "WARN" "${message}"
}

function log_error {
  local readonly message="$1"
  log "ERROR" "${message}"
}

function assert_not_empty {
  local readonly arg_name="$1"
  local readonly arg_value="$2"

  if [[ -z "${arg_value}" ]]; then
    log_error "The value for '${arg_name}' cannot be empty"
    print_usage
    exit 1
  fi
}

function assert_is_installed {
  local readonly name="$1"

  if [[ ! $(command -v ${name}) ]]; then
    log_error "The binary '${name}' is required by this script but is not installed or in the system's PATH."
    exit 1
  fi
}

# Based on: http://unix.stackexchange.com/a/7732/215969
function get_owner_of_path {
  local readonly path="$1"
  ls -ld "$path" | awk '{print $3}'
}

function wait_for_consul {
  local consul_leader

  for (( i=1; i<="$MAX_RETRIES"; i++ )); do
    consul_leader=$(
      curl -sS http://localhost:8500/v1/status/leader 2> /dev/null || echo "failed"
    )

    if [[ "${consul_leader}" = "failed" ]]; then
      log_warn "Failed to find Consul cluster leader. Will sleep for $SLEEP_BETWEEN_RETRIES_SEC seconds and try again."
      sleep "$SLEEP_BETWEEN_RETRIES_SEC"
    else
      log_info "Found Consul leader at ${consul_leader}"
      return
    fi
  done

  log_error "Failed to detect Consul agent after $MAX_RETRIES retries. Did you start a Consul agent before running the script?"
  exit 1
}

function lookup_path_in_instance_metadata {
  local readonly path="$1"
  curl --silent --location "$EC2_INSTANCE_METADATA_URL/$path/"
}

function lookup_path_in_instance_dynamic_data {
  local readonly path="$1"
  curl --silent --location "$EC2_INSTANCE_DYNAMIC_DATA_URL/$path/"
}

function get_instance_ip_address {
  lookup_path_in_instance_metadata "local-ipv4"
}

function get_instance_region {
  lookup_path_in_instance_dynamic_data "instance-identity/document" | jq -r ".region"
}

function consul_kv {
  local readonly path="${1}"
  local value
  value=$(consul kv get "${path}") || exit $?
  log_info "Consul KV Path ${path} = ${value}"
  echo -n "${value}"
}

function consul_kv_with_default {
  local readonly path="${1}"
  local readonly default="${2}"
  local value
  value=$(consul kv get "${path}" || echo -n "${default}") || exit $?
  log_info "Consul KV Path ${path} = ${value}"
  echo -n "${value}"
}

# Signal service if it exists
function signal_service {
  local readonly service="${1}"
  local readonly signal="${2}"

  supervisorctl status "${service}" && supervisorctl signal "${signal}" "${service}"
}

function get_vault_token {
  local readonly token_role="${1}"
  local readonly address="${2}"

  log_info "Retrieving Vault token with role ${token_role}"

  local token
  token=$(
    vault token create -address "${address}" -role "${token_role}" -format json
  ) || exit $?

  if echo -n "${token}" | jq --raw-output -e .errors > /dev/null; then
    log_error "Failed to obtain Vault token"
    log_error "${token}"
    exit 1
  else
    echo -n "${token}" | jq --raw-output .auth.client_token
  fi
}

function generate_vault_config {
  local readonly server="${1}"
  local readonly config_dir="${2}"
  local readonly vault_address="${3}"
  local readonly consul_prefix="${4}"
  local readonly user="${5}"

  if [[ "$server" == "true" ]]; then
    log_info "Generating Vault configuration for Nomad server"
    local allow_unauthenticated
    allow_unauthenticated=$(consul_kv "${consul_prefix}allow_unauthenticated")

    local nomad_cluster_role
    nomad_cluster_role=$(consul_kv "${consul_prefix}nomad_cluster_role")

    local nomad_server_role
    nomad_server_role=$(consul_kv "${consul_prefix}nomad_server_role")

    local vault_token
    vault_token=$(get_vault_token "${nomad_server_role}" "${vault_address}")

    local default_config=$(cat <<EOF
vault {
  enabled = true
  address = "$vault_address"
  token = "$vault_token"
  allow_unauthenticated = $allow_unauthenticated
  create_from_role = "$nomad_cluster_role"
}
EOF
)
  else
    log_info "Generating Vault configuration for Nomad client"

    local default_config=$(cat <<EOF
vault {
  enabled = true
  address = "$vault_address"
}
EOF
)
  fi

  log_info "Writing Vault configuration to ${config_dir}/vault.hcl"
  echo "${default_config}" > "${config_dir}/vault.hcl"
  chown "${user}:${user}" "${config_dir}/vault.hcl"
}

function generate_acl_config {
  local readonly config_dir="${1}"
  local readonly user="${2}"

  local default_config=$(cat <<EOF
acl {
  enabled = true
}
EOF
)

  log_info "Writing ACL configuration to ${config_dir}/acl.hcl"
  echo "${default_config}" > "${config_dir}/acl.hcl"
  chown "${user}:${user}" "${config_dir}/acl.hcl"
}

function generate_docker_config {
  local readonly consul_prefix="${1}"
  local readonly config_dir="${2}"
  local readonly user="${3}"
  local readonly consul_template_config="${4}"
  local readonly docker_auth_path="${5}"

  local docker_config=$(cat <<EOF
client {
  options {
    "docker.auth.config" = "${docker_auth_path}"
  }
}
EOF
)

  log_info "Writing Docker configuration to ${config_dir}/docker.hcl"
  echo "${docker_config}" > "${config_dir}/docker.hcl"
  chown "${user}:${user}" "${config_dir}/docker.hcl"

  local vault_path
  vault_path=$(consul_kv "${consul_prefix}docker-auth/path")

  local docker_template=$(cat <<EOF
template {
  destination = "${docker_auth_path}"
  create_dest_dirs = true

  # consul-template does not deal with ownership properly
  # See https://github.com/hashicorp/consul-template/issues/1061
  command = "bash -c 'chown ${user}:${user} ${docker_auth_path}'"

  perms = 0600
  error_on_missing_key = true

  # The goal is to produce something like
  # {
  #     "auths": {
  #         "registry.a.b": {
  #           "auth": "aaaaa="
  #         },
  #         "foo.bar.xyz": {
  #           "auth": "bbbb="
  #         }
  #     }
  # }
  #
  # But two things make it difficult:
  # 1. JSON doesn't do dangling commas
  # 2. Go Template has really basic logic handling
  #
  # Thus this template is more complicated than needed.
  contents = <<EOH
{{- define "keys" -}}
  {{- with secret "${vault_path}" }}
      {{- range \$key, \$value := .Data -}}
        {{ \$key }}{{ " " }}
      {{- end -}}
  {{- end -}}
{{- end -}}
{{- \$keys := (executeTemplate "keys" | trimSpace | split " ") -}}
{
    "auths": {
    {{- with secret "${vault_path}" -}}
    {{ \$auths := .Data }}
      {{- range \$i, \$key := \$keys }}
        {{- if \$i }},{{ end }}
        "{{ \$key }}": {
          "auth": "{{ index \$auths \$key }}"
        }
      {{- end }}
    {{- end }}
    }
}
EOH
}
EOF
)
  log_info "Writing Consul Template configuration to ${consul_template_config}/template_nomad_docker.hcl"
  echo "${docker_template}" > "${consul_template_config}/template_nomad_docker.hcl"
}

function generate_tls_config {
  local readonly server="${1}"
  local readonly consul_prefix="${2}"
  local readonly config_dir="${3}"
  local readonly user="${4}"
  local readonly consul_template_config="${5}"
  local readonly cert_path="${6}"

  # TLS configuration
  local tls_server_config=""
  local bootstrap=$(consul_kv "${consul_prefix}nomad-tls/bootstrap")
  if [[ "$server" == "true" && "$bootstrap" == "yes" ]]; then
    tls_server_config=$(cat <<EOF
server {
  heartbeat_grace = "1h"
}
EOF
)
  fi

  # TLS Configuration
  local tls_config=$(cat <<EOF
tls {
  http = true
  rpc  = true

  ca_file = "${cert_path}/ca.pem"
  cert_file = "${cert_path}/cert.pem"
  key_file = "${cert_path}/key.pem"

  verify_server_hostname = true
  verify_https_client = false
}

${tls_server_config}
EOF
)

  log_info "Writing TLS configuration to ${config_dir}/tls.hcl"
  echo "${tls_config}" > "${config_dir}/tls.hcl"
  chown "${user}:${user}" "${config_dir}/tls.hcl"

  # Consul Templates
  # Based off https://github.com/hashicorp/consul-template/blob/master/examples/vault-pki.md
  local role
  if [[ "$server" == "true" ]]; then
    role=$(consul_kv "${consul_prefix}nomad-tls/server_role")
  else
    role=$(consul_kv "${consul_prefix}nomad-tls/client_role")
  fi

  local pki_path
  pki_path=$(consul_kv "${consul_prefix}nomad-tls/pki_path")

  local instance_ip_address=""
  local instance_region=""

  instance_ip_address=$(get_instance_ip_address)
  instance_region=$(get_instance_region)

  local pki_param
  if [[ "$server" == "true" ]]; then
    pki_param="\"common_name=server.${instance_region}.nomad\" \"alt_names=nomad.service.consul\" \"ip_sans=${instance_ip_address},127.0.0.1\""
  else
    pki_param="\"common_name=client.${instance_region}.nomad\" \"ip_sans=${instance_ip_address},127.0.0.1\""
  fi

  local ca_template=$(cat <<EOF
template {
  destination = "${cert_path}/ca.pem"
  create_dest_dirs = true

  # consul-template does not deal with ownership properly
  # See https://github.com/hashicorp/consul-template/issues/1061
  command = "bash -c 'chown ${user}:${user} ${cert_path}/ca.pem && (supervisorctl signal SIGHUP nomad || true)'"

  perms = 0600
  error_on_missing_key = true

  contents = <<EOH
{{- with secret "${pki_path}/issue/${role}" ${pki_param} -}}
  {{- .Data.issuing_ca -}}
{{- end -}}
EOH
}
EOF
)

  log_info "Writing TLS CA Consul Template configuration to ${consul_template_config}/template_nomad_tls_ca.hcl"
  echo "${ca_template}" > "${consul_template_config}/template_nomad_tls_ca.hcl"

  local cert_template=$(cat <<EOF
template {
  destination = "${cert_path}/cert.pem"
  create_dest_dirs = true

  # consul-template does not deal with ownership properly
  # See https://github.com/hashicorp/consul-template/issues/1061
  command = "bash -c 'chown ${user}:${user} ${cert_path}/cert.pem && (supervisorctl signal SIGHUP nomad || true)'"

  perms = 0600
  error_on_missing_key = true

  contents = <<EOH
{{- with secret "${pki_path}/issue/${role}" ${pki_param} -}}
  {{- .Data.certificate -}}
{{- end -}}
EOH
}
EOF
)

  log_info "Writing TLS Certificate Consul Template configuration to ${consul_template_config}/template_nomad_tls_cert.hcl"
  echo "${cert_template}" > "${consul_template_config}/template_nomad_tls_cert.hcl"

  local key_template=$(cat <<EOF
template {
  destination = "${cert_path}/key.pem"
  create_dest_dirs = true

  # consul-template does not deal with ownership properly
  # See https://github.com/hashicorp/consul-template/issues/1061
  command = "bash -c 'chown ${user}:${user} ${cert_path}/key.pem && (supervisorctl signal SIGHUP nomad || true)'"

  perms = 0600
  error_on_missing_key = true

  contents = <<EOH
{{- with secret "${pki_path}/issue/${role}" ${pki_param} -}}
  {{- .Data.private_key -}}
{{- end -}}
EOH
}
EOF
)

  log_info "Writing TLS Key Consul Template configuration to ${consul_template_config}/template_nomad_tls_key.hcl"
  echo "${key_template}" > "${consul_template_config}/template_nomad_tls_key.hcl"

  # Server Gossip encryption
  if [[ "$server" == "true" ]]; then

  local gossip_path
  gossip_path=$(consul_kv "${consul_prefix}nomad-tls/gossip_path")
  local gossip_template=$(cat <<EOF
template {
  destination = "${config_dir}/gossip.hcl"

  # consul-template does not deal with ownership properly
  # See https://github.com/hashicorp/consul-template/issues/1061
  command = "bash -c 'chown ${user}:${user} ${config_dir}/gossip.hcl && (supervisorctl signal SIGHUP nomad || true)'"

  perms = 0600
  error_on_missing_key = true

  contents = <<EOH
server {
  encrypt = "{{- with secret "${gossip_path}" -}}{{- .Data.key -}}{{- end -}}"
}
EOH
}
EOF
)

  log_info "Writing Gossip Consul Template configuration to ${consul_template_config}/template_nomad_gossip.hcl"
  echo "${gossip_template}" > "${consul_template_config}/template_nomad_gossip.hcl"
  fi

  signal_service "consul-template" "SIGHUP"
}

function main {
  local server="false"
  local client="false"
  local config_dir=""
  local vault_address="https://vault.service.consul:8200"
  local consul_prefix="terraform/"
  local user=""
  local consul_template_config="/opt/consul-template/config"
  local docker_auth=""
  local cert_path=""
  local all_args=()

  while [[ $# > 0 ]]; do
    local key="$1"

    case "$key" in
      --server)
        server="true"
        ;;
      --client)
        client="true"
        ;;
      --config-dir)
        assert_not_empty "$key" "$2"
        config_dir="$2"
        shift
      ;;
      --vault-address)
        assert_not_empty "$key" "$2"
        vault_address="$2"
        shift
        ;;
      --consul-prefix)
        assert_not_empty "$key" "$2"
        consul_prefix="$2"
        shift
        ;;
      --user)
        assert_not_empty "$key" "$2"
        user="$2"
        shift
        ;;
      --consul-template-config)
        assert_not_empty "$key" "$2"
        consul_template_config="$2"
        shift
        ;;
      --docker-auth)
        assert_not_empty "$key" "$2"
        cert_path="$2"
        shift
        ;;
      --cert-path)
        assert_not_empty "$key" "$2"
        docker_auth="$2"
        shift
        ;;
      --help)
        print_usage
        exit
        ;;
      *)
        log_error "Unrecognized argument: $key"
        print_usage
        exit 1
        ;;
    esac

    shift
  done

  if [[ ("$server" == "true" && "$client" == "true") || ("$server" == "false" && "$client" == "false") ]]; then
    log_error "Exactly one of --server or --client must be set."
    exit 1
  fi

  assert_is_installed "curl"
  assert_is_installed "tr"
  assert_is_installed "jq"
  assert_is_installed "consul"
  assert_is_installed "consul-template"

  wait_for_consul

  if [[ -z "$config_dir" ]]; then
    config_dir="$(cd "$SCRIPT_DIR/../config" && pwd)"
  fi

  if [[ -z "$docker_auth" ]]; then
    docker_auth="$(cd "$SCRIPT_DIR/.." && pwd)/docker.json"
  fi

  if [[ -z "$cert_path" ]]; then
    mkdir -p "$SCRIPT_DIR/../certs"
    cert_path="$(cd "$SCRIPT_DIR/../certs" && pwd)"
  fi

  if [[ -z "$user" ]]; then
    user=$(get_owner_of_path "$config_dir")
  fi

  local vault_integration_enabled
  vault_integration_enabled=$(consul_kv_with_default "${consul_prefix}nomad-vault-integration/enabled" "no")
  if [[ "${vault_integration_enabled}" != "yes" ]]; then
    log_info "Nomad Vault integration is not enabled"
  else
    assert_is_installed "vault"
    generate_vault_config "${server}" "${config_dir}" "${vault_address}" "${consul_prefix}nomad-vault-integration/" "${user}"
  fi

  local acl_integration_enabled
  acl_integration_enabled=$(consul_kv_with_default "${consul_prefix}nomad-acl/enabled" "no")
  if [[ "${acl_integration_enabled}" != "yes" ]]; then
    log_info "Nomad ACL is not enabled"
  else
    generate_acl_config "${config_dir}" "${user}"
  fi

  local docker_auth_enabled
  docker_auth_enabled=$(consul_kv_with_default "${consul_prefix}docker-auth/enabled" "no")
  if [[ "${docker_auth_enabled}" != "yes" || "$server" == "true" ]]; then
    log_info "Docker authentication is not enabled or this is a Nomad server."
  else
    generate_docker_config "${consul_prefix}" "${config_dir}" "${user}" "${consul_template_config}" "${docker_auth}"
  fi

  local tls_enabled
  tls_enabled=$(consul_kv_with_default "${consul_prefix}nomad-tls/enabled" "no")
  if [[ "${tls_enabled}" != "yes" ]]; then
    log_info "Nomad TLS is not enabled"
  else
    generate_tls_config "${server}" "${consul_prefix}" "${config_dir}" "${user}" "${consul_template_config}" "${cert_path}"
  fi
}

main "$@"
