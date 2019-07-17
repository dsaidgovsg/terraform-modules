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

readonly SYSTEMCTL="systemctl"
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
  echo -e "  --skip-token-out\t\tSkip writing the Vault token passed to Consul Template to the \"~/.vault-token\" of the user provided above. Optional. Default is false"
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

# Based on https://unix.stackexchange.com/a/23213
function append_paths {
  if [ $# -eq 0 ]; then return 1; fi
  printf '%s' "${1%/}"
  shift
  if [ $# -gt 0 ]; then printf '/%s' "${@%/}"; fi
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

function assert_os_get_ctl {
  # https://superuser.com/questions/291210/how-to-get-amazon-ec2-instance-operating-system-info#answer-291242
  local readonly is_ubuntu=$(cat /etc/issue | grep "Ubuntu")
  local readonly is_amazon_linux=$(cat /etc/issue | grep "Amazon Linux")

  if [[ "${is_ubuntu}" ]]; then
    assert_is_installed "$SYSTEMCTL"
    echo "$SYSTEMCTL"
  elif [[ "${is_amazon_linux}" ]]; then
    assert_is_installed "$INITCTL"
    echo "$INITCTL"
  else
    log_error "Only Ubuntu and Amazon Linux are currently supported."
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
      curl -sS "$(append_paths "${consul_agent}" "v1/status/leader")" 2> /dev/null || echo "failed"
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
    curl -Ss -XPOST --retry 5 \
      "$(append_paths "${address}" "v1/auth" "${auth_path}" "login")" \
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

function generate_systemd_config {
  local readonly systemd_config_path="$1"
  local readonly consul_template_config_dir="$2"
  local readonly consul_template_log_dir="$3"
  local readonly consul_template_bin_dir="$4"
  local readonly consul_template_user="$5"
  local readonly consul_template_environment="$(join_by " " ${@:6})"

  log_info "Creating Systemd config file to run Consul Template in $systemd_config_path"

  local -r unit_config=$(cat <<EOF
[Unit]
Description="Consul-Template - A daemon tool for populating values from Consul/Vault into the file system"
Documentation=https://github.com/hashicorp/consul-template
Requires=network-online.target
After=network-online.target
ConditionDirectoryNotEmpty=$consul_template_config_dir
EOF
)
  
  local -r service_config=$(cat <<EOF
[Service]
User=$consul_template_user
Group=$consul_template_user
ExecStart=$consul_template_bin_dir/consul-template -config $consul_template_config_dir
ExecStop=/bin/kill -s SIGINT \$MAINPID
ExecReload=/bin/kill -s SIGHUP \$MAINPID
KillMode=process
Restart=on-failure
LimitNOFILE=65536
Environment=$consul_template_environment
StandardOutput=syslog
StandardError=syslog
EOF
)

  local -r install_config=$(cat <<EOF
[Install]
WantedBy=multi-user.target
EOF
)

  echo -e "$unit_config" > "$systemd_config_path"
  echo -e "$service_config" >> "$systemd_config_path"
  echo -e "$install_config" >> "$systemd_config_path"
}

function generate_upstart_config {
  local readonly upstart_config_path="$1"
  local readonly consul_template_config_dir="$2"
  local readonly consul_template_log_dir="$3"
  local readonly consul_template_bin_dir="$4"
  local readonly consul_template_user="$5"
  local readonly consul_template_environment="$(join_by "," ${@:6})"

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

  if [[ "${ctl}" == "$INITCTL" ]]; then
    shift
    generate_upstart_config "$@"
  elif [[ "${ctl}" == "$SYSTEMCTL" ]]; then
    shift
    generate_systemd_config "$@"
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
  auth_path=$(consul_kv "$(append_paths "${consul_prefix}" "path")")

  # Get the role. If the server_type is invalid, this will fail
  local token_role
  token_role=$(consul_kv "$(append_paths "${consul_prefix}" "roles" "${server_type}")")

  local vault_token
  vault_token=$(request_vault_token "${auth_path}" "${token_role}" "${vault_address}") || exit $?

  echo -n "${vault_token}"
}

function start_consul_template_for_systemd {
  log_info "Reloading Systemd config and starting Consul Template"
  systemctl daemon-reload
  systemctl restart consul-template
}

function start_consul_template_for_upstart {
  log_info "Reloading Upstart config and starting Consul Template"
  initctl reload-configuration
}

function start_consul_template {
  local readonly ctl="${1}"

  if [[ "${ctl}" == "$INITCTL" ]]; then
    start_consul_template_for_upstart
  elif [[ "${ctl}" == "$SYSTEMCTL" ]]; then
    start_consul_template_for_systemd
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
  local skip_token_out="false"
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
      --skip-token-out)
        skip_token_out="true"
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

  # For initctl and systemctl switching
  local readonly ctl="$(assert_os_get_ctl)"

  if [[ "${ctl}" == "$INITCTL" ]]; then
    readonly config_ctl_path="/etc/init/run-consul-template.conf"
  elif [[ "${ctl}" == "$SYSTEMCTL" ]]; then
    readonly config_ctl_path="/etc/systemd/system/consul-template.service"
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
    aws_auth_enabled=$(consul_kv_with_default "$(append_paths "${consul_prefix}" "aws-auth/enabled")" "no")
    if [[ "${aws_auth_enabled}" != "yes" ]]; then
      log_info "AWS Authentication is not enabled"
    else

      local vault_token
      vault_token=$(get_vault_token "${vault_address}" "$(append_paths "${consul_prefix}" "aws-auth")" "${server_type}") || exit $?
      environment+=("VAULT_TOKEN=${vault_token}")

      generate_vault_config "${vault_address}" "$config_dir" "$user"

      if [[ "$skip_token_out" == "false" ]]; then
        local token_destination="$(get_home_directory "${user}")/.vault-token"
        log_info "Writing Vault token to the home directory: ${token_destination}"

        echo -n "${vault_token}" > "${token_destination}"
      fi
    fi
  fi

  generate_ctl_config "$ctl" "$config_ctl_path" "$config_dir" "$log_dir" "$bin_dir" "$user" "${environment[@]}"
  start_consul_template "$ctl"
}

run "$@"
