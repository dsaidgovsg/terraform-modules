#!/bin/bash
# This script is used to configure and run consul-template on an AWS server.
# You have to place your templates and additional configuration files in the necessary paths before
# you start Consul Template

set -e

readonly DEFAULT_CONFIG_FILE="default.hcl"

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

readonly MAX_RETRIES=30
readonly SLEEP_BETWEEN_RETRIES_SEC=10

function print_usage {
  echo
  echo "Usage: run-consul-template [OPTIONS]"
  echo
  echo "This script is used to configure and run Consul-template on an AWS server."
  echo
  echo "Options:"
  echo
  echo -e "  --config-dir\t\tThe path to the Consul config folder. Optional. Default is the absolute path of '../config', relative to this script."
  echo -e "  --log-dir\t\tThe path to the Consul log folder. Optional. Default is the absolute path of '../log', relative to this script."
  echo -e "  --bin-dir\t\tThe path to the folder with Consul binary. Optional. Default is the absolute path of the parent folder of this script."
  echo -e "  --user\t\tThe user to run Consul as. Optional. Default is to use the owner of --config-dir."
  echo -e "  --agent-address\t\tThe address of the Consul agent to access. Optional. Defaults to 127.0.0.1:8500"
  echo -e "  --dedup-enable\t\tEnable deduplication mode. Optional. Defaults to false"
  echo -e "  --dedup-prefix\t\tPrefix to use for deduplication mode. Optional. Defaults to \"consul-template/dedup/\""
  echo -e "  --syslog-enable\t\tEnable logging to syslog. Optional. Defaults to false"
  echo -e "  --syslog-facility\t\tThe syslog facility to log to. Optional. Defaults to \"LOCAL5\""
  echo -e "  --skip-config\tIf this flag is set, don't generate a Consul-template configuration file. Optional. Default is false."
  echo
  echo "Example:"
  echo
  echo "  run-consul-template --config-dir /custom/path/to/consul/config"
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

# Based on code from: http://stackoverflow.com/a/16623897/483528
function strip_prefix {
  local readonly str="$1"
  local readonly prefix="$2"
  echo "${str#$prefix}"
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

function generate_consul_template_config {
  local readonly config_dir="${1}"
  local readonly user="${2}"
  local readonly agent_address="${3}"
  local readonly dedup_enable="${4}"
  local readonly dedup_prefix="${5}"
  local readonly syslog_enable="${6}"
  local readonly syslog_facility="${7}"
  local readonly config_path="$config_dir/$DEFAULT_CONFIG_FILE"


  local dedup_config=""
  if [[ "$dedup_enable" == true && ! -z "$dedup_prefix" ]]; then
    dedup_config=$(cat <<EOF
deduplicate {
  enabled = true
  prefix = "${dedup_prefix}"
}
EOF
)
  fi

  local syslog_config=""
  if [[ "$syslog_enable" == "true" && ! -z "$syslog_facility" ]]; then
    syslog_config=$(cat <<EOF
syslog_config {
  enabled = true
  facility = "${syslog_facility}"
}
EOF
)
  fi

  log_info "Creating default Consul Template configuration"
  local default_config_hcl=$(cat <<EOF
consul {
    address = "${agent_address}"
}

reload_signal = "SIGHUP"
kill_signal = "SIGINT"
${dedup_config}
${syslog_config}
EOF
)
  log_info "Installing Consul config file in $config_path"
  echo "$default_config_hcl" "$config_path"
  chown "$user:$user" "$config_path"
}

function generate_supervisor_config {
  local readonly supervisor_config_path="$1"
  local readonly consul_template_config_dir="$2"
  local readonly consul_template_log_dir="$3"
  local readonly consul_template_bin_dir="$4"
  local readonly consul_template_user="$5"

  log_info "Creating Supervisor config file to run Consul Template in $supervisor_config_path"
  cat > "$supervisor_config_path" <<EOF
[program:consul-template]
command=$consul_template_bin_dir/consul-template -config $consul_template_config_dir
stdout_logfile=$consul_template_log_dir/consul-template-stdout.log
stderr_logfile=$consul_template_log_dir/consul-template-error.log
numprocs=1
autostart=true
autorestart=true
stopsignal=INT
user=$consul_template_user
EOF
}

function start_consul_template {
  log_info "Reloading Supervisor config and starting Consul Template"

  supervisorctl reread
  supervisorctl update
}

# Based on: http://unix.stackexchange.com/a/7732/215969
function get_owner_of_path {
  local readonly path="$1"
  ls -ld "$path" | awk '{print $3}'
}

function run {
  local config_dir=""
  local log_dir=""
  local bin_dir=""
  local user=""
  local agent_address="127.0.0.1:8500"
  local dedup_enable="false"
  local dedup_prefix="consul-template/dedup/"
  local syslog_enable="false"
  local syslog_facility="LOCAL5"
  local skip_config="false"
  local all_args=()

  while [[ $# > 0 ]]; do
    local key="$1"

    case "$key" in
      --config-dir)
        assert_not_empty "$key" "$2"
        config_dir="$2"
        shift
        ;;
      --log-dir)
        assert_not_empty "$key" "$2"
        log_dir="$2"
        shift
        ;;
      --bin-dir)
        assert_not_empty "$key" "$2"
        bin_dir="$2"
        shift
        ;;
      --user)
        assert_not_empty "$key" "$2"
        user="$2"
        shift
        ;;
      --agent-address)
        assert_not_empty "$key" "$2"
        agent_address="$2"
        shift
        ;;
      --dedup-enable)
        dedup_enable="true"
        ;;
      --dedup-prefix)
        assert_not_empty "$key" "$2"
        dedup_prefix="$2"
        shift
        ;;
      --syslog-enable)
        syslog_enable="true"
        ;;
      --syslog-facility)
        assert_not_empty "$key" "$2"
        syslog_facility="$2"
        shift
        ;;
      --skip-config)
        skip_config="true"
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

  assert_is_installed "supervisorctl"
  assert_is_installed "consul-template"

  if [[ -z "$config_dir" ]]; then
    config_dir=$(cd "$SCRIPT_DIR/../config" && pwd)
  fi

  if [[ -z "$log_dir" ]]; then
    log_dir=$(cd "$SCRIPT_DIR/../log" && pwd)
  fi

  if [[ -z "$bin_dir" ]]; then
    bin_dir=$(cd "$SCRIPT_DIR/../bin" && pwd)
  fi

  if [[ -z "$user" ]]; then
    user=$(get_owner_of_path "$config_dir")
  fi

  if [[ "$skip_config" == "true" ]]; then
    log_info "The --skip-config flag is set, so will not generate a default Consul Template config file."
  else
    generate_consul_template_config "$config_dir" "$user" "$agent_address" "$dedup_enable" "$dedup_prefix" "$syslog_enable" "$syslog_facility"
  fi

  generate_supervisor_config "$SUPERVISOR_CONFIG_PATH" "$config_dir" "$log_dir" "$bin_dir" "$user"
  start_consul_template
}

run "$@"
