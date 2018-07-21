#!/bin/bash
# This script is used to configure and run consul-template on an AWS server.
# You have to place your templates and additional configuration files in the necessary paths before
# you start Consul Template. Otherwise, nothing will happen.

set -e

readonly DEFAULT_CONFIG_FILE="default.hcl"
readonly VAULT_CONFIG_FILE="vault.hcl"
readonly VAULT_TOKEN_TEMPLATE="template_vault_token.hcl"

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

readonly MAX_RETRIES=30
readonly SLEEP_BETWEEN_RETRIES_SEC=10

readonly SUPERVISORCTL="supervisorctl"
readonly INITCTL="initctl"

function print_usage {
  echo
  echo "Usage: run-consul-template [OPTIONS]"
  echo
  echo "This script is used to configure and run Consul-template on an AWS server."
  echo
  echo "Options:"
  echo
  echo -e "  --server-type\t\tType of server. Required, unless --skip-vault is set."
  echo -e "  --config-dir\t\tThe path to the Consul config folder. Optional. Default is the absolute path of '../config', relative to this script."
  echo -e "  --log-dir\t\tThe path to the Consul log folder. Optional. Default is the absolute path of '../log', relative to this script."
  echo -e "  --bin-dir\t\tThe path to the folder with Consul binary. Optional. Default is the absolute path of the parent folder of this script."
  echo -e "  --user\t\tThe user to run Consul as. Optional. Default is to use the owner of --config-dir."
  echo -e "  --agent-address\t\tThe address of the Consul agent to access. Optional. Defaults to 127.0.0.1:8500"
  echo -e "  --dedup-enable\t\tEnable deduplication mode. Optional. Defaults to false"
  echo -e "  --dedup-prefix\t\tPrefix to use for deduplication mode. Optional. Defaults to \"consul-template/dedup/\""
  echo -e "  --syslog-enable\t\tEnable logging to syslog. Optional. Defaults to false"
  echo -e "  --syslog-facility\t\tThe syslog facility to log to. Optional. Defaults to \"LOCAL5\""
  echo -e "  --consul-prefix\t\tPath prefix in Consul KV store to query for integration status. Optional. Defaults to terraform/"
  echo -e "  --vault-address\t\tAddress of the Vault server.  Optional. Defaults to \"https://vault.service.consul:8200\""
  echo -e "  --skip-render-self-template\t\tSkip render the Vault token passed to Consul Template to the \"~/.vault-token\" of the user provided above. Optional. Default is false"
  echo -e "  --skip-config\tIf this flag is set, don't generate a Consul-template configuration file. Optional. Default is false."
  echo -e "  --skip-vault\t\tIf this flag is set, don't attempt to obtain a Vault token using the aws-auth integration. Optional. Default is false."
  echo
  echo "Example:"
  echo
  echo "  run-consul-template --server-type consul --config-dir /custom/path/to/consul/config"
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

# Based on https://stackoverflow.com/a/17841619
function join_by {
  local IFS="$1"
  shift
  echo "$*"
}

# Based on code from: http://stackoverflow.com/a/16623897/483528
function strip_prefix {
  local readonly str="$1"
  local readonly prefix="$2"
  echo "${str#$prefix}"
}

function check_is_installed {
  local readonly name="$1"
  echo $(command -v "${name}")
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

  if [[ ! $(check_is_installed ${name}) ]]; then
    echo "The binary '$name' is required by this script but is not installed or in the system's PATH."
    exit 1
  fi
}

# From https://superuser.com/a/484330
function get_home_directory {
  local readonly user="${1}"

  getent passwd "${user}" | cut -d: -f6
}

function wait_for_consul {
  local readonly consul_agent="${1}"
  local consul_leader

  for (( i=1; i<="$MAX_RETRIES"; i++ )); do
    consul_leader=$(
      curl -sS "${consul_agent}/v1/status/leader" 2> /dev/null || echo "failed"
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

function request_vault_token {
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
    curl -Ss -XPOST "${address}/v1/auth/${auth_path}login" \
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

function generate_base_config {
  local readonly config_dir="${1}"
  local readonly user="${2}"
  local readonly agent_address="${3}"
  local readonly dedup_enable="${4}"
  local readonly dedup_prefix="${5}"
  local readonly syslog_enable="${6}"
  local readonly syslog_facility="${7}"
  local readonly config_path="$config_dir/$DEFAULT_CONFIG_FILE"


  local dedup_config=""
  if [[ "$dedup_enable" == "true" && ! -z "$dedup_prefix" ]]; then
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
syslog {
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

log_level = "info"
reload_signal = "SIGHUP"
kill_signal = "SIGINT"
${dedup_config}
${syslog_config}
EOF
)
  log_info "Installing base config file in $config_path"
  echo "$default_config_hcl" > "$config_path"
  chown "$user:$user" "$config_path"
}

function generate_supervisor_config {
  local readonly supervisor_config_path="$1"
  local readonly consul_template_config_dir="$2"
  local readonly consul_template_log_dir="$3"
  local readonly consul_template_bin_dir="$4"
  local readonly consul_template_user="$5"
  local readonly consul_template_environment="$6"

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
environment=$consul_template_environment
EOF
}

function generate_upstart_config {
  local readonly upstart_config_path="$1"
  local readonly consul_template_config_dir="$2"
  local readonly consul_template_log_dir="$3"
  local readonly consul_template_bin_dir="$4"
  local readonly consul_template_user="$5"
  local readonly consul_template_environment="$6"

  log_info "Creating Upstart config file to run Consul Template in $upstart_config_path"
  cat > "$upstart_config_path" <<EOF
description "Consul Template"

start on (runlevel [2345] and started network)
stop on (runlevel [!2345] or stopping network)

# Allow service to revive after crash
respawn

script
  export PATH=/usr/local/bin:$PATH $consul_template_environment

  # https://superuser.com/questions/213416/running-upstart-jobs-as-unprivileged-users
  # https://stackoverflow.com/questions/8251933/how-can-i-log-the-stdout-of-a-process-started-by-start-stop-daemon
  exec /usr/local/bin/start-stop-daemon --start -c $consul_template_user \
    --make-pidfile --pidfile /var/run/consul-template.pid \
    --startas /bin/bash -- -c \
    "exec '"$consul_template_bin_dir/consul-template"' -config '"$consul_template_config_dir"' >> '"$consul_template_log_dir/consul-template-stdout.log"' 2>&1"
end script
EOF
}

function generate_ctl_config {
  local readonly ctl="${1}"
  
  if [[ "${ctl}" == "$SUPERVISORCTL" ]]; then
    shift
    generate_supervisor_config "$@"
  elif [[ "${ctl}" == "$INITCTL" ]]; then
    shift
    generate_initctl_config "$@"
  fi
}

function generate_vault_config {
  local readonly vault_address="${1}"
  local readonly config_dir="${2}"
  local readonly user="${3}"
  local readonly config_path="$config_dir/$VAULT_CONFIG_FILE"

  log_info "Generating Vault configuration for Consul Template"

  local vault_config_hcl=$(cat <<EOF
vault {
  address = "${vault_address}"
  unwrap_token = false
  renew_token = true
}
EOF
)
  log_info "Installing Vault config file in $config_path"
  echo "$vault_config_hcl" > "$config_path"
  chown "$user:$user" "$config_path"
}

function get_vault_token {
  local readonly vault_address="${1}"
  local readonly consul_prefix="${2}"
  local readonly server_type="${3}"

  # Get the authentication path
  local auth_path
  auth_path=$(consul_kv "${consul_prefix}path")

  # Get the role. If the server_type is invalid, this will fail
  local token_role
  token_role=$(consul_kv "${consul_prefix}roles/${server_type}")

  local vault_token
  vault_token=$(request_vault_token "${auth_path}" "${token_role}" "${vault_address}") || exit $?

  echo -n "${vault_token}"
}

function render_self_template {
  local readonly config_dir="${1}"
  local readonly user="${2}"
  local readonly config_path="$config_dir/$VAULT_TOKEN_TEMPLATE"

  local template_destination
  template_destination="$(get_home_directory "${user}")/.vault-token"

  log_info "Generating Vault token template for Consul Template"

  local vault_token_template=$(cat <<EOF
template {
  contents = "{{ with secret \\"auth/token/lookup-self\\" }}{{ .Data.id }}{{ end }}"
  destination = "${template_destination}"
  create_dest_dirs = true
  error_on_missing_key = true
  perms = 0600
}
EOF
)
  log_info "Installing Vault token template configuration file in $config_path"
  echo "$vault_token_template" > "$config_path"
  chown "$user:$user" "$config_path"
}

function start_consul_template_for_supervisor {
  log_info "Reloading Supervisor config and starting Consul Template"

  supervisorctl reread
  supervisorctl update
}

function start_consul_template_for_upstart {
  log_info "Reloading Upstart config and starting Consul Template"
  initctl reload-configuration
}

function start_consul_template {
  local readonly ctl="${1}"

  if [[ "${ctl}" == "$SUPERVISORCTL" ]]; then
    start_consul_template_for_supervisor
  elif [[ "${ctl}" == "$INITCTL" ]]; then
    start_consul_template_for_upstart
  fi
}

# Based on: http://unix.stackexchange.com/a/7732/215969
function get_owner_of_path {
  local readonly path="$1"
  ls -ld "$path" | awk '{print $3}'
}

function run {
  local server_type=""
  local config_dir=""
  local log_dir=""
  local bin_dir=""
  local user=""
  local agent_address="127.0.0.1:8500"
  local dedup_enable="false"
  local dedup_prefix="consul-template/dedup/"
  local syslog_enable="false"
  local syslog_facility="LOCAL5"
  local consul_prefix="terraform/"
  local vault_address="https://vault.service.consul:8200"
  local skip_config="false"
  local skip_vault="false"
  local skip_render_self_template="false"
  local environment=()
  local all_args=()

  while [[ $# > 0 ]]; do
    local key="$1"

    case "$key" in
      --server-type)
        assert_not_empty "$key" "$2"
        server_type="$2"
        shift
        ;;
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
      --consul-prefix)
        assert_not_empty "$key" "$2"
        consul_prefix="$2"
        shift
        ;;
      --vault-address)
        assert_not_empty "$key" "$2"
        vault_address="$2"
        shift
        ;;
      --skip-config)
        skip_config="true"
        ;;
      --skip-vault)
        skip_vault="true"
        ;;
      --skip-render-self-template)
        skip_render_self_template="true"
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

  # For supervisorctl and initctl switching
  local readonly has_supervisorctl="$(check_is_installed "$SUPERVISORCTL")"
  local readonly has_initctl="$(check_is_installed "$INITCTL")"
  local readonly ctl=$(([[ $has_supervisorctl ]] && echo "$SUPERVISORCTL") || ([[ $has_initctl ]] && echo "$INITCTL"))

  if [[ ! "${ctl}" ]]; then
    log_error "Need $SUPERVISORCTL or $INITCTL to continue configuration."
    exit 1
  fi

  if [[ "${ctl}" == "$SUPERVISORCTL" ]]; then
    readonly config_ctl_path="/etc/supervisor/conf.d/run-consul-template.conf"
  elif [[ "${ctl}" == "$INITCTL" ]]; then
    readonly config_ctl_path="/etc/init/run-consul-template.conf"
  fi

  assert_is_installed "consul"
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
    generate_base_config "$config_dir" "$user" "$agent_address" "$dedup_enable" "$dedup_prefix" "$syslog_enable" "$syslog_facility"
  fi

  if [[ "$skip_vault" == "true" ]]; then
    log_info "The --skip-vault flag is set, so will not generate try to obtain a Vault token."
  else
    if [[ -z "$server_type" ]]; then
      log_error "You must specify the --server-type"
      exit 1
    fi

    assert_is_installed "curl"
    assert_is_installed "jq"
    wait_for_consul "http://${agent_address}" # XXX: What about TLS in future?

    local aws_auth_enabled
    aws_auth_enabled=$(consul_kv_with_default "${consul_prefix}aws-auth/enabled" "no")
    if [[ "${aws_auth_enabled}" != "yes" ]]; then
      log_info "AWS Authentication is not enabled"
    else

      local vault_token
      vault_token=$(get_vault_token "${vault_address}" "${consul_prefix}aws-auth/" "${server_type}") || exit $?
      environment+=("VAULT_TOKEN=\"${vault_token}\"")

      generate_vault_config "${vault_address}" "$config_dir" "$user"

      if [[ "$skip_render_self_template" == "false" ]]; then
        log_info "Configuring consul-template to render its Vault token to the home directory."

        render_self_template "${config_dir}" "${user}"
      fi
    fi
  fi

  generate_ctl_config "$ctl" "$config_ctl_path" "$config_dir" "$log_dir" "$bin_dir" "$user" "$(join_by "," "${environment[@]}")"
  start_consul_template "$ctl"
}

run "$@"
