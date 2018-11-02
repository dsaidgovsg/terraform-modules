#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

readonly MAX_RETRIES=30
readonly SLEEP_BETWEEN_RETRIES_SEC=10

function print_usage {
  echo
  echo "Usage: prometheus [OPTIONS]"
  echo
  echo "This script is used to configure a Prometheus instance."
  echo
  echo "Options:"
  echo
  echo -e "  --server-type\t\tType of server for integrations with other modules. Optional. Defaults to 'prometheus'."
  echo -e "  --consul-config\t\Consul configuration directory. Optional. Defaults to '/opt/consul/config'."
  echo -e "  --consul-prefix\t\tPath prefix in Consul KV store to query for integration status. Optional. Defaults to terraform/"
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

# Based on: http://unix.stackexchange.com/a/7732/215969
function get_owner_of_path {
  local readonly path="$1"
  ls -ld "$path" | awk '{print $3}'
}

function generate_consul_config {
  local readonly consul_prefix="${1}"
  local readonly consul_config="${2}"

  local readonly consul_destination="${consul_config}/prometheus.hcl"

  local readonly prometheus_service=$(consul_kv "${consul_prefix}prometheus/service_name")
  local readonly prometheus_port=$(consul_kv "${consul_prefix}prometheus/port")

  local readonly traefik_enabled=$(consul_kv_with_default "${consul_prefix}prometheus/traefik/enabled" "no")

  local traefik_tags=""

  if [[ "$traefik_enabled" == "yes" ]]; then
    local readonly traefik_fqdns=$(consul_kv "${consul_prefix}prometheus/traefik/fqdns")
    local readonly traefik_entrypoints=$(consul_kv "${consul_prefix}prometheus/traefik/entrypoints")

    traefik_tags=$(cat <<EOF
    "traefik.enable=true",
    "traefik.frontend.rule=Host:${traefik_fqdns}",
    "traefik.frontend.entryPoints=${traefik_entrypoints}",
    "traefik.frontend.headers.SSLRedirect=true",
    "traefik.frontend.headers.SSLProxyHeaders=X-Forwarded-Proto:https",
    "traefik.frontend.headers.STSSeconds=315360000",
    "traefik.frontend.headers.frameDeny=true",
    "traefik.frontend.headers.browserXSSFilter=true",
    "traefik.frontend.headers.contentTypeNosniff=true",
    "traefik.frontend.headers.referrerPolicy=strict-origin",
    "traefik.frontend.headers.contentSecurityPolicy=default-src 'self';",
EOF
)
  fi

  local consul=$(cat <<EOF
service {
  name = "${prometheus_service}"
  port = ${prometheus_port}

  tags = [
    ${traefik_tags}
  ]

  check {
    name     = "Prometheus Targets"
    http     = "http://127.0.0.1:${prometheus_port}/api/v1/targets"
    method   = "GET"
    interval = "30s"
    timeout  = "2s"
  }
}
EOF
)

  log_info "Writing Consul configuration to ${consul_destination}"
  echo -n "${consul}" > "${consul_destination}"
  local readonly consul_owner=$(get_owner_of_path "${consul_config}")
  chown "${consul_owner}:${consul_owner}" "${consul_destination}"
}

function mount_ebs {
  local readonly data_device_name="${1}"
  local readonly db_dir="${2}"

  until ls "${data_device_name}"; do
    log_info "Waiting for data device ${data_device_name} to be mounted"
    sleep 5
  done

  log_info "Mounting data volume"
  mkdir -p "${db_dir}"
  mount "${data_device_name}" "${db_dir}"

  local readonly uuid="$(blkid -s UUID -o value "${data_device_name}")"
  echo "" >> /etc/fstab
  echo "UUID=${uuid} ${db_dir} ext4 defaults,nofail" >> /etc/fstab
  # Safety Check
  mount -a
}
function main {
  local consul_config="/opt/consul/config"
  local server_type="prometheus"
  local consul_prefix="terraform/"
  local all_args=()

  while [[ $# > 0 ]]; do
    local key="$1"

    case "$key" in
      --consul-config)
        assert_not_empty "$key" "$2"
        consul_config="$2"
        shift
        ;;
      --server-type)
        assert_not_empty "$key" "$2"
        server_type="$2"
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

  assert_is_installed "curl"
  assert_is_installed "consul"

  wait_for_consul

  generate_consul_config "${consul_prefix}" "${consul_config}"

  local readonly data_device_name=$(consul_kv "${consul_prefix}prometheus/data_device_name")
  local readonly db_dir=$(consul_kv "${consul_prefix}prometheus/db_dir")
  mount_ebs "$data_device_name" "$db_dir"
}

main "$@"
