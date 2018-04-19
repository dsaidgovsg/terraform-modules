#!/usr/bin/env bash
set -euo pipefail

# Note: This script works assumes that the non-configurable  defaults setup by the Ansible roles
# and the `core` and `nomad-vault-integration` modules are not changed. Otherwise, it will fail to
# find the right values and will not work.

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

readonly MAX_RETRIES=30
readonly SLEEP_BETWEEN_RETRIES_SEC=10

function print_usage {
  echo
  echo "Usage: configure-vault [OPTIONS]"
  echo
  echo "This script is used to configure Nomad for Vault integration on an AWS server."
  echo
  echo "Options:"
  echo
  echo -e "  --server\t\tIf set, configure in server mode. Optional. Exactly one of --server or --client must be set."
  echo -e "  --client\t\tIf set, configure in client mode. Optional. Exactly one of --server or --client must be set."
  echo -e "  --config-path\t\tThe path to write the config file to. Optional. Default is the absolute path of '../config/vault.hcl', relative to this script."
  echo -e "  --vault-service\t\tName of Vault service to query in Consul. Optional. Defaults to 'vault'."
  echo -e "  --vault-port\t\tPort of Vault service. Optional. Defaults to '8200'."
  echo -e "  --consul-prefix\t\tPath prefix in Consul KV store to query for Vault configuration status. Optional. Defaults to terraform/nomad-vault-integration/"
  echo
  echo "Example:"
  echo
  echo "  configure-vault --server"
}

function log {
  local readonly level="$1"
  local readonly message="$2"
  local readonly timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  >&2 echo -e "${timestamp} [${level}] [$SCRIPT_NAME] ${message}"
}

function log_info {
  local readonly message="$1"
  log "INFO" "$message"
}

function log_warn {
  local readonly message="$1"
  log "WARN" "$message"
}

function log_error {
  local readonly message="$1"
  log "ERROR" "$message"
}

function assert_not_empty {
  local readonly arg_name="$1"
  local readonly arg_value="$2"

  if [[ -z "$arg_value" ]]; then
    log_error "The value for '$arg_name' cannot be empty"
    print_usage
    exit 1
  fi
}

function assert_is_installed {
  local readonly name="$1"

  if [[ ! $(command -v ${name}) ]]; then
    log_error "The binary '$name' is required by this script but is not installed or in the system's PATH."
    exit 1
  fi
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


function consul_kv {
  local readonly path="${1}"
  local value
  value=$(consul kv get "${path}") || exit $?
  log_info "Consul KV Path ${path} = ${value}"
  echo -n "${value}"
}

function get_vault_token {
  local readonly auth_path="${1}"
  local readonly token_role="${2}"
  local readonly address="${3}"

  log_info "Retrieving EC2 Identity Document"
  local ec2_identity
  ec2_identity=$(
    curl -s http://169.254.169.254/latest/dynamic/instance-identity/pkcs7 | tr -d '\n'
  ) || exit $?

  log_info "Retrieving Vault token at path ${auth_path} with role ${token_role}"

  local token
  token=$(
    curl -Ss -XPOST "${address}/v1/auth/${auth_path}/login" \
      -d '{ "role": "'"${token_role}"'", "pkcs7": "'"${ec2_identity}"'" }'
  ) || exit $?

  if echo -n "${token}" | jq --raw-output -e .errors > /dev/null; then
    log_error "Failed to obtain Vault token"
    log_error "${token}"
    exit 1
  else
    echo -n "${token}" | jq --raw-output .auth.client_token
  fi
}

function generate_config {
  local readonly server="${1}"
  local readonly config_path="${2}"
  local readonly vault_address="${3}"
  local readonly consul_prefix="${4}"

   if [[ "$server" == "true" ]]; then
    local auth_path
    auth_path=$(consul_kv "${consul_prefix}auth_path")
    local token_role
    token_role=$(consul_kv "${consul_prefix}nomad_server_role")

    local vault_token
    vault_token=$(get_vault_token "${auth_path}" "${token_role}" "${vault_address}")

    local allow_unauthenticated
    allow_unauthenticated=$(consul_kv "${consul_prefix}allow_unauthenticated")

    local create_from_role
    create_from_role=$(consul_kv "${consul_prefix}create_from_role")

    local default_config=$(cat <<EOF
vault {
  enabled = true
  address = "$vault_address"
  allow_unauthenticated = $allow_unauthenticated
  create_from_role = "$create_from_role"
  token = "$vault_token"
}
EOF
)
  else
    local default_config=$(cat <<EOF
vault {
  enabled = true
  address = "$vault_address"
}
EOF
)
  fi

  log_info "Writing Vault configuration to ${config_path}"
  echo "${default_config}" > "${config_path}"
}

function main {
  local server="false"
  local client="false"
  local config_path=""
  local vault_service="vault"
  local vault_port="8200"
  local consul_prefix="terraform/nomad-vault-integration/"
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
      --config-path)
        assert_not_empty "$key" "$2"
        config_path="$2"
        shift
      ;;
      --vault-service)
        assert_not_empty "$key" "$2"
        vault_service="$2"
        shift
        ;;
      --vault-port)
        assert_not_empty "$key" "$2"
        vault_port="$2"
        shift
        ;;
      --consul-prefix)
        assert_not_empty "$key" "$2"
        consul_prefix="$2"
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

  wait_for_consul

  local integration_enabled
  integration_enabled=$(consul_kv "${consul_prefix}enabled")
  if [[ "${integration_enabled}" != "yes" ]]; then
    log_info "Nomad Vault integration is not enabled"
    exit 0
  fi

  if [[ -z "$config_path" ]]; then
    config_path="$(cd "$SCRIPT_DIR/../config" && pwd)/vault.hcl"
  fi

  local readonly vault_address="https://${vault_service}.service.consul:${vault_port}"

  generate_config "${server}" "${config_path}" "${vault_address}" "${consul_prefix}"
}

main "$@"
