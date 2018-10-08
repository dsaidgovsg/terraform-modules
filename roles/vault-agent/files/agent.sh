#!/bin/bash
# This script is used to configure and run Vault agent on an AWS server.

set -e

readonly VAULT_CONFIG_FILE="agent.hcl"
readonly SUPERVISOR_CONFIG_PATH="/etc/supervisor/conf.d/run-vault.conf"

readonly DEFAULT_PORT=8200
readonly DEFAULT_LOG_LEVEL="info"

readonly EC2_INSTANCE_METADATA_URL="http://169.254.169.254/latest/meta-data"

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

function print_usage {
  echo
  echo "Usage: agent [OPTIONS]"
  echo
  echo "This script is used to configure and run Vault Agent on an AWS server."
  echo
  echo "Options:"
  echo
  echo -e "  --address\t\tSpecifies the Address of the Vault server. Optional. Default is 'https://vault.service.consul:8200'"
  echo -e "  --role\t\tSpecifies the authentication role. Required."
  echo -e "  --auth-mount\t\tThe mount path of the method. Optional. Defaults to 'auth/aws'"
  echo -e "  --log-level\t\tThe log verbosity to use with Vault. Optional. Default is $DEFAULT_LOG_LEVEL."
  echo -e "  --log-dir\t\tThe path to the Vault log folder. Optional. Default is the absolute path of '../agent/log', relative to this script."
  echo -e "  --config-dir\t\tThe path to the Vault config folder. Optional. Default is the absolute path of '../agent/config', relative to this script."
  echo -e "  --bin-dir\t\tThe path to the folder with Vault binary. Optional. Default is the absolute path of the parent folder of this script."
  echo -e "  --ca-cert\t\tPath on the local disk to a single PEM-encoded CA certificate to verify the Vault server's SSL certificate. Optional"
  echo -e "  --ca-path\t\tPath on the local disk to a directory of PEM-encoded CA certificates to verify the Vault server's SSL certificate. Optional."
  echo -e "  --client-cert\t\tPath on the local disk to a single PEM-encoded CA certificate to use for TLS authentication to the Vault server. If this flag is specified, --client-key is also required. Optional."
  echo -e "  --client-key\t\tPath on the local disk to a single PEM-encoded private key matching the client certificate from --client-cert. Optional."
  echo -e "  --tls-server-name\t\tName to use as the SNI host when connecting to the Vault server via TLS. Optional."
  echo -e "  --exit-after-auth\t\tExit the agent after running. Optional. Defaults to false"
  echo -e "  --output\t\tPath to output the Vault token to. Repeat this option for additional paths. Requires at least one."
  echo -e "  --user\t\tThe user to run Vault as. Optional. Default is to use the owner of --config-dir."
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

function lookup_path_in_instance_metadata {
  local readonly path="$1"
  curl --silent --location "$EC2_INSTANCE_METADATA_URL/$path/"
}

function get_instance_ip_address {
  lookup_path_in_instance_metadata "local-ipv4"
}

# Based on https://stackoverflow.com/a/17841619
function join_by {
  local IFS="$1"
  shift
  echo "$*"
}

function assert_is_installed {
  local readonly name="$1"

  if [[ ! $(command -v ${name}) ]]; then
    log_error "The binary '$name' is required by this script but is not installed or in the system's PATH."
    exit 1
  fi
}

function generate_vault_config {
  local readonly config_dir="$1"
  local readonly auth_mount="$2"
  local readonly exit_after_auth="$3"
  local readonly user="$4"
  shift 4
  local readonly output=("$@")

  local readonly config_path="$config_dir/$VAULT_CONFIG_FILE"

  local sinks=""

  for (( i=0; i<${#output[@]}; i++)); do
    sinks=$(cat <<EOF
${sinks}

  sink "file" {
    config {
      path = "${output[$i]}"
    }
  }
EOF
)
  done

  local agent_config
  agent_config=$(cat <<EOF

exit_after_auth = ${exit_after_auth}

auto_auth {
  method "aws" {
    mount_path = "${auth_mount}"

    config {
      type = "ec2"
      role = "${auth_role}"
    }
  }

  ${sinks}
}

EOF
)

  log_info "Creating default Vault agent config file in $config_path"
  echo -e "${agent_config}" > "$config_path"

  chown "$user:$user" "$config_path"
}

function generate_supervisor_config {
  local readonly supervisor_config_path="$1"
  local readonly vault_config_dir="$2"
  local readonly vault_bin_dir="$3"
  local readonly vault_log_dir="$4"
  local readonly vault_log_level="$5"
  local readonly vault_user="$6"
  local readonly exit_after_auth="$7"
  local readonly address="$8"
  local readonly ca_cert="$9"
  local readonly ca_path="${10}"
  local readonly client_cert="${11}"
  local readonly client_key="${12}"
  local readonly tls_server_name="${13}"

  local readonly config_path="$vault_config_dir/$VAULT_CONFIG_FILE"

  local auto_restart="true"
  if [ "${exit_after_auth}" = "true" ]; then
    auto_restart="false"
  fi

  local environment=()
  environment+=("VAULT_ADDR=\"${address}\"")
  if [ ! -z "$ca_cert" ]; then
    environment+=("VAULT_CACERT=\"${ca_cert}\"")
  fi
  if [ ! -z "$ca_path" ]; then
    environment+=("VAULT_CAPATH=\"${ca_path}\"")
  fi
  if [ ! -z "$client_cert" ]; then
    environment+=("VAULT_CLIENT_CERT=\"${client_cert}\"")
  fi
  if [ ! -z "$client_key" ]; then
    environment+=("VAULT_CLIENT_KEY=\"${client_key}\"")
  fi
  if [ ! -z "$tls_server_name" ]; then
    environment+=("VAULT_TLS_SERVER_NAME=\"${tls_server_name}\"")
  fi

  log_info "Creating Supervisor config file to run Vault agent in $supervisor_config_path"
  cat > "$supervisor_config_path" <<EOF
[program:vault]
command=$vault_bin_dir/vault agent -config=$config_path -log-level=$vault_log_level
stdout_logfile=$vault_log_dir/vault-stdout.log
stderr_logfile=$vault_log_dir/vault-error.log
numprocs=1
autostart=true
autorestart=${auto_restart}
stopsignal=INT
user=$vault_user
environment=$(join_by "," "${environment[@]}")
EOF
}

function start_vault {
  log_info "Reloading Supervisor config and starting Vault Agent"
  supervisorctl reread
  supervisorctl update
}

# Based on: http://unix.stackexchange.com/a/7732/215969
function get_owner_of_path {
  local readonly path="$1"
  ls -ld "$path" | awk '{print $3}'
}

function run {
  local address="https://vault.service.consul:8200"
  local config_dir=""
  local bin_dir=""
  local log_dir=""
  local log_level="$DEFAULT_LOG_LEVEL"
  local ca_cert=""
  local ca_path=""
  local client_cert=""
  local client_key=""
  local tls_server=""
  local user=""
  local role=""
  local auth_mount="auth/aws"
  local exit_after_auth="false"
  local output=()
  local all_args=()

  while [[ $# > 0 ]]; do
    local key="$1"

    case "$key" in
      --address)
        address="$2"
        shift
        ;;
      --config-dir)
        assert_not_empty "$key" "$2"
        config_dir="$2"
        shift
        ;;
      --bin-dir)
        assert_not_empty "$key" "$2"
        bin_dir="$2"
        shift
        ;;
      --ca-cert)
        ca_cert="$2"
        shift
        ;;
      --ca-path)
        assert_not_empty "$key" "$2"
        ca_path="$2"
        shift
        ;;
      --client-cert)
        assert_not_empty "$key" "$2"
        client_cert="$2"
        shift
        ;;
      --client-key)
        assert_not_empty "$key" "$2"
        client_key="$2"
        shift
        ;;
       --tls-server)
        assert_not_empty "$key" "$2"
        tls_server="$2"
        shift
        ;;
      --log-level)
        assert_not_empty "$key" "$2"
        log_level="$2"
        shift
        ;;
      --log-dir)
        assert_not_empty "$key" "$2"
        log_dir="$2"
        shift
        ;;
      --user)
        assert_not_empty "$key" "$2"
        user="$2"
        shift
        ;;
      --auth-mount)
        assert_not_empty "$key" "$2"
        auth_mount="$2"
        shift
        ;;
      --role)
        assert_not_empty "$key" "$2"
        role="$2"
        shift
        ;;
      --exit-after-auth)
        exit_after_auth="true"
        ;;
      --output)
        assert_not_empty "$key" "$2"
        output+=("$2")
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

  assert_not_empty "--role" "${role}"

  if [ ${#output[@]} -eq 0 ]; then
    log_error "At least one --output must be specified"
  fi

  assert_is_installed "supervisorctl"
  assert_is_installed "jq"

  if [[ -z "$config_dir" ]]; then
    config_dir=$(cd "$SCRIPT_DIR/../agent/config" && pwd)
  fi

  if [[ -z "$log_dir" ]]; then
    log_dir=$(cd "$SCRIPT_DIR/../agent/log" && pwd)
  fi

  if [[ -z "$bin_dir" ]]; then
    bin_dir=$(cd "$SCRIPT_DIR/../bin" && pwd)
  fi

  if [[ -z "$user" ]]; then
    user=$(get_owner_of_path "$config_dir")
  fi

  generate_vault_config "${config_dir}" "${auth_mount}" \
    "${exit_after_auth}" "${user}" "${output[@]}"

  generate_supervisor_config "${SUPERVISOR_CONFIG_PATH}" "${config_dir}" "${bin_dir}" "${log_dir}" \
    "${log_level}" "${user}" "${exit_after_auth}" "${address}" "${ca_cert}" "${client_cert}" \
    "${client_key}" "${tls_server_name}"

  start_vault
}

run "$@"
