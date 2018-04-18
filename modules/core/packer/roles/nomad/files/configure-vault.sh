#!/usr/bin/env bash
set -euo pipefail

# Note: This script works assumes that there is a Consul agent running on localhost and that
# DNSMasq has been setup to query the Consul agent.

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
  echo -e "  --config-dir\t\tThe path to write the config file to. Optional. Default is the absolute path of '../config/vault.hcl', relative to this script."
  echo -e "  --vault-service\t\tName of Vault service to query in Consul. Optional. Defaults to 'vault'."
  echo -e "  --vault-port\t\Port of Vault service. Optional. Defaults to '8200'."
  echo
  echo "Example:"
  echo
  echo "  configure-vault --server"
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

function generate_config {
  local readonly server="${1}"
  local readonly config_path="${2}"
  local readonly vault_address="${3}"

}

function main {
  local server="false"
  local client="false"
  local config_path=""
  local vault_service="vault"
  local vault_port="8200"
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
  assert_is_installed "jq"
  assert_is_installed "consul"
  assert_is_installed "vault"

  if [[ -z "$config_path" ]]; then
    config_path=$(cd "$SCRIPT_DIR/../config/vault.hcl" && pwd)
  fi

  local readonly vault_address="https://${vault_service}.service.consul:${vault_port}"

  generate_config "${server}" "${config_path}" "${vault_address}"
}

main "$@"
