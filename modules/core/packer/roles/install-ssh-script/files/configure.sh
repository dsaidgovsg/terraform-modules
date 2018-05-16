#!/usr/bin/env bash
set -euo pipefail

# Note: This script works assumes that the non-configurable defaults setup by the Ansible roles
# and the `core` and `vault-ssh` modules are not changed. Otherwise, it will fail to
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
  echo -e "  --type\t\tThe type of instance being configured. Required. Can be 'consul', 'vault', 'nomad_client' or 'nomad_server'."
  echo -e "  --vault-service\t\tName of Vault service to query in Consul. Optional. Defaults to 'vault'."
  echo -e "  --vault-port\t\tPort of Vault service. Optional. Defaults to '8200'."
  echo -e "  --consul-prefix\t\tPath prefix in Consul KV store to query for integration status. Optional. Defaults to terraform/"
  echo
  echo "Example:"
  echo
  echo "  configure --type vault"
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

function consul_kv_with_default {
  local readonly path="${1}"
  local readonly default="${2}"
  local value
  value=$(consul kv get "${path}" || echo -n "${default}") || exit $?
  log_info "Consul KV Path ${path} = ${value}"
  echo -n "${value}"
}

function generate_config {
  local readonly vault_address="${1}"
  local readonly path="${2}"

  local readonly certificate_path="/etc/ssh/trusted-user-ca-keys.pem"
  # Download certificate
  log_info "Downloading CA certificate to ${certificate_path}"
  curl -sSo "${certificate_path}" "${vault_address}/v1/${path}/public_key"

  # Append to sshd config
  log_info "Appending configuration to SSHD"
  echo "TrustedUserCAKeys ${certificate_path}" >> /etc/ssh/sshd_config

  log_info "Restarting SSHD"
  service sshd restart
}

function main {
  local type=""
  local vault_service="vault"
  local vault_port="8200"
  local consul_prefix="terraform/"
  local all_args=()

  while [[ $# > 0 ]]; do
    local key="$1"

    case "$key" in
      --type)
        assert_not_empty "$key" "$2"
        type="$2"
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

  if [[ "${type}" != "vault" && "${type}" != "consul" && "${type}" != "nomad_server" && "${type}" != "nomad_client" ]]; then
    log_error "Invalid type set."
    exit 1
  fi

  assert_is_installed "curl"
  assert_is_installed "consul"
  assert_is_installed "sshd"

  wait_for_consul

  local readonly vault_address="https://${vault_service}.service.consul:${vault_port}"

  local ssh_enabled
  ssh_enabled=$(consul_kv_with_default "${consul_prefix}vault-ssh/${type}/enabled" "no")
  if [[ "${ssh_enabled}" != "yes" ]]; then
    log_info "Vault SSH is not enabled"
  else
    local path
    path=$(consul_kv "${consul_prefix}vault-ssh/${type}/path")
    generate_config "${vault_address}" "${path}"
  fi
}

main "$@"
