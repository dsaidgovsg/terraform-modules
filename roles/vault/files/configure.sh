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
  echo "Usage: configure [OPTIONS]"
  echo
  echo "This script is used for additional Vault configuration"
  echo
  echo "Options:"
  echo
  echo -e "  --consul-prefix\t\tPath prefix in Consul KV store to query for integration status. Optional. Defaults to terraform/"
  echo -e "  --config-dir\t\tThe path to the Consul config folder. Optional. Default is the absolute path of '../config', relative to this script."
  echo -e "  --user\t\tThe user to CHOWN the config files as. Optional. Default is to use the owner of --config-dir."
  echo -e "  --statsd-addr\t\tThe address of the DogStatsD server to report to. Optional. Defaults to '127.0.0.1:8125'"
  echo -e "  --telegraf-conf\t\tThe directory to place Telegraf config files in. Optional. Defaults to '/etc/telegraf/telegraf.d'"
  echo -e "  --lb-listener-port\t\tThe port to create a listener for ELB. Optional. Defaults to 8300"
  echo -e "  --x-forwarded-for-addrs\t\tComma separated list of source IP addresses for which an \`X-Forwarded-For\` header will be trusted. Optional. Defaults to empty."
  echo -e "  --tls-cert-file\tSpecifies the path to the certificate for ELB TLS. Required. To use a CA certificate, concatenate the primary certificate and the CA certificate together."
  echo -e "  --tls-key-file\tSpecifies the path to the private key for the certificate. Required."
  echo
  echo "Example:"
  echo
  echo "  configure"
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

function generate_telemetry_conf {
  local readonly conf_file="${1}"
  local readonly user="${2}"
  local readonly service="${3}"
  local readonly statsd_addr="${4}"

  local telemetry_config=$(cat <<EOF
telemetry {
  dogstatsd_addr = "${statsd_addr}"
  dogstatsd_tags = ["_service:${service}"]
  disable_hostname = true
}
EOF
)

  log_info "Writing Telemetry Configuration for Vault to ${conf_file}"
  echo "${telemetry_config}" > "${conf_file}"
  chown "${user}:${user}" "${conf_file}"
}

function generate_telegraf_procstat {
  local readonly telegraf_conf="${1}"
  local readonly pgrep_pattern="${2}"

  local procstat=$(cat <<EOF
# Monitor process cpu and memory usage
[[inputs.procstat]]
exe = "${pgrep_pattern}"
EOF
)

  log_info "Writing Procstat Telemetry Configuration for Telegraf to ${telegraf_conf}"
  echo "${procstat}" > "${telegraf_conf}"
}

function generate_lb_listener {
  local readonly conf_file="${1}"
  local readonly user="${2}"
  local readonly lb_listener_port="${3}"
  local readonly x_forwarded_for_addrs="${4}"
  local readonly tls_cert_file="${5}"
  local readonly tls_key_file="${6}"

  local elb_listener
  elb_listener=$(cat <<EOF
listener "tcp" {
  address = "0.0.0.0:${lb_listener_port}"
  tls_cert_file   = "${tls_cert_file}"
  tls_key_file    = "${tls_key_file}"

  x_forwarded_for_authorized_addrs   = "${x_forwarded_for_addrs}"
  x_forwarded_for_reject_not_present = false
}
EOF
)

  log_info "Writing ELB Listener Configuration for Vault to ${conf_file}"
  echo "${elb_listener}" > "${conf_file}"
  chown "${user}:${user}" "${conf_file}"
}

function main {
  local consul_prefix="terraform/"
  local config_dir=""
  local user=""
  local statsd_addr="127.0.0.1:8125"
  local telegraf_conf="/etc/telegraf/telegraf.d"
  local lb_listener_port="8300"
  local x_forwarded_for_addrs=""
  local tls_cert_file=""
  local tls_key_file=""

  while [[ $# > 0 ]]; do
    local key="$1"

    case "$key" in
      --consul-prefix)
        assert_not_empty "$key" "$2"
        consul_prefix="$2"
        shift
        ;;
      --config-dir)
        assert_not_empty "$key" "$2"
        config_dir="$2"
        shift
        ;;
      --user)
        assert_not_empty "$key" "$2"
        user="$2"
        shift
        ;;
      --statsd-addr)
        assert_not_empty "$key" "$2"
        statsd_addr="$2"
        shift
        ;;
      --telegraf-conf)
        assert_not_empty "$key" "$2"
        telegraf_conf="$2"
        shift
        ;;
      --lb-listener-port)
        assert_not_empty "$key" "$2"
        lb_listener_port="$2"
        shift
        ;;
      --x-forwarded-for-addrs)
        assert_not_empty "$key" "$2"
        x_forwarded_for_addrs="$2"
        shift
        ;;
      --tls-cert-file)
        tls_cert_file="$2"
        shift
        ;;
      --tls-key-file)
        tls_key_file="$2"
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

  assert_not_empty "--tls-cert-file" "$tls_cert_file"
  assert_not_empty "--tls-key-file" "$tls_key_file"

  if [[ -z "$config_dir" ]]; then
    config_dir=$(cd "$SCRIPT_DIR/../config" && pwd)
  fi

  if [[ -z "$user" ]]; then
    user=$(get_owner_of_path "$config_dir")
  fi

  assert_is_installed "consul"
  wait_for_consul

  local readonly type="vault"
  local readonly telegraf_enabled=$(consul_kv_with_default "${consul_prefix}telegraf/server_types/${type}/enabled" "no")

  generate_lb_listener "${config_dir}/elb.hcl" "${user}" "${lb_listener_port}" "${x_forwarded_for_addrs}" "${tls_cert_file}" "${tls_key_file}"

  if [[ "$telegraf_enabled" != "yes" ]]; then
    log_info "Telegraf metrics is not enabled for ${type}"
  else
    generate_telemetry_conf "${config_dir}/telemetry.hcl" "${user}" "${type}" "${statsd_addr}"
    generate_telegraf_procstat "${telegraf_conf}/procstat_consul.conf" "^vault\$"
  fi
}

main "$@"
