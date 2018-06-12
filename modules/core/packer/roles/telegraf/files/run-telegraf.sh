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
  echo "Usage: run-telegraf [OPTIONS]"
  echo
  echo "This script is used to configure Telegraf on an AWS server."
  echo
  echo "Options:"
  echo
  echo -e "  --type\t\tThe type of instance being configured. Required. Keys must exist in Consul for the server type"
  echo -e "  --consul-prefix\t\tPath prefix in Consul KV store to query for integration status. Optional. Defaults to terraform/"
  echo -e "  --skip-template\t\tEnable consul-template apply on configuration file. Optional. Defaults to false."
  echo -e "  --conf-template\t\tFile path to configuration consul-template file. Optional. Defaults to /etc/telegraf/telegraf.conf.template"
  echo -e "  --conf-out\t\tFile path to configuration destination. Optional. Defaults to /etc/telegraf/telegraf.conf"
  echo
  echo "Example:"
  echo
  echo "  run-telegraf --type consul"
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

function main {
  local type=""
  local consul_prefix="terraform/"
  local skip_template="false"
  local conf_template="/etc/telegraf/telegraf.conf.template"
  local conf_out="/etc/telegraf/telegraf.conf"

  local readonly service_override_dir="/etc/systemd/system/telegraf.service.d"

  while [[ $# > 0 ]]; do
    local key="$1"

    case "$key" in
      --type)
        assert_not_empty "$key" "$2"
        type="$2"
        shift
        ;;
      --consul-prefix)
        assert_not_empty "$key" "$2"
        consul_prefix="$2"
        shift
        ;;
      --skip-template)
        skip_template="false"
        ;;
      --conf-template)
        assert_not_empty "$key" "$2"
        conf_template="$2"
        shift
        ;;
      --conf-out)
        assert_not_empty "$key" "$2"
        conf_out="$2"
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

  if [[ -z "${type}" ]]; then
    log_error "You must specify the --type"
    exit 1
  fi

  assert_is_installed "consul"
  assert_is_installed "consul-template"

  wait_for_consul

  local readonly enabled=$(consul_kv_with_default "${consul_prefix}telegraf/${type}/enabled" "no")

  if [[ "$enabled" != "yes" ]]; then
    log_info "Telegraf is not enabled for ${type}"
  else
    if [[ "$skip_template" == "false" && -f "$conf_template" ]]; then
      consul-template -template "$conf_template:$conf_out" -once
    fi

    mkdir -p "$service_override_dir"
    echo -e "[Service]\nEnvironment=SERVICE_NAME=$type" > "$service_override_dir/override.conf"

    systemctl enable telegraf
    systemctl start telegraf
  fi
}

main "$@"
