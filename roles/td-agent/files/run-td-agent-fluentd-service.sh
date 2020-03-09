#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

readonly MAX_RETRIES=30
readonly SLEEP_BETWEEN_RETRIES_SEC=10

function print_usage {
  echo
  echo "Usage: run-td-agent [OPTIONS]"
  echo
  echo "This script is used to configure td-agent on an AWS server."
  echo
  echo "Options:"
  echo
  echo -e "  --rotate-age\t\tLog rotation age. Optional. Defaults to 5"
  echo -e "  --rotate-size\t\tLog rotation size. Optional. Defaults to 104857600"
  echo
  echo "Example:"
  echo
  echo "  run-td-agent --conf-out /etc/td-agent/td-agent.conf"
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

function enable_td_agent {
  local readonly service_override_dir="${1}"
  local readonly rotate_age="${2}"
  local readonly rotate_size="${3}"

  log_info "Enabling and starting service td-agent for Fluentd service ..."

  mkdir -p "${service_override_dir}"

  # To override an existing value ExecStart, the value must be set to empty first
  local readonly override_conf=$(cat <<EOF
[Service]
ExecStart=
ExecStart=/opt/td-agent/embedded/bin/fluentd --log /var/log/td-agent/td-agent.log --log-rotate-age ${rotate_age} --log-rotate-size ${rotate_size} --daemon /var/run/td-agent/td-agent.pid \$TD_AGENT_OPTIONS
EOF
)
  echo "${override_conf}" > "${service_override_dir}/override.conf"

  systemctl enable td-agent
  systemctl start td-agent

  log_info "Service td-agent enabled and started!"
}

function main {
  local conf_out="/etc/td-agent/td-agent.conf"
  local rotate_age="5"
  local rotate_size="104857600"

  local readonly service_override_dir="/etc/systemd/system/td-agent.service.d"

  while [[ $# > 0 ]]; do
    local key="$1"

    case "$key" in
      --rotate-age)
        assert_not_empty "$key" "$2"
        rotate_age="$2"
        shift
        ;;
      --rotate-size)
        assert_not_empty "$key" "$2"
        rotate_size="$2"
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

  enable_td_agent "${service_override_dir}" "${rotate_age}" "${rotate_size}"

}

main "$@"
