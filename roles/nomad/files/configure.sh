#!/usr/bin/env bash
set -euo pipefail

# Note: This script works assumes that the non-configurable defaults setup by the Ansible roles
# and the `core` and `nomad-vault-integration` modules are not changed. Otherwise, it will fail to
# find the right values and will not work.

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

readonly MAX_RETRIES=30
readonly SLEEP_BETWEEN_RETRIES_SEC=10

function print_usage {
  echo
  echo "Usage: configure [OPTIONS]"
  echo
  echo "This script is used to configure Nomad for Vault integration on an AWS server."
  echo
  echo "Options:"
  echo
  echo -e "  --server\t\tIf set, configure in server mode. Optional. Exactly one of --server or --client must be set."
  echo -e "  --client\t\tIf set, configure in client mode. Optional. Exactly one of --server or --client must be set."
  echo -e "  --config-dir\t\tThe path to write the config files to. Optional. Default is the absolute path of '../config', relative to this script."
  echo -e "  --vault-address\t\tAddress of Vault server. Optional. Defaults to \"https://vault.service.consul:8200\""
  echo -e "  --consul-prefix\t\tPath prefix in Consul KV store to query for integration status. Optional. Defaults to terraform/"
  echo -e "  --consul-template-config\t\tPath to directory of configuration files for Consul Template. Optional. Defaults to `/opt/consul-template/config`"
  echo -e "  --docker-auth\t\tPath to store Docker authentication information. Optional. Default is the absolute path of '../docker.json', relative to this script."
  echo -e "  --statsd-addr\t\tThe address of the DogStatsD server to report to. Optional. Defaults to '127.0.0.1:8125'"
  echo -e "  --telegraf-conf\t\tThe directory to place Telegraf config files in. Optional. Defaults to '/etc/telegraf/telegraf.d'"
  echo -e "  --user\t\tThe user to run Nomad as. Optional. Default is to use the owner of --config-dir."
  echo
  echo "Example:"
  echo
  echo "  configure --server"
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

function get_vault_token {
  local readonly token_role="${1}"
  local readonly address="${2}"

  log_info "Retrieving Vault token with role ${token_role}"

  local token
  token=$(
    vault token create -address "${address}" -role "${token_role}" -format json
  ) || exit $?

  if echo -n "${token}" | jq --raw-output -e .errors > /dev/null; then
    log_error "Failed to obtain Vault token"
    log_error "${token}"
    exit 1
  else
    echo -n "${token}" | jq --raw-output .auth.client_token
  fi
}

function generate_vault_config {
  local readonly server="${1}"
  local readonly config_dir="${2}"
  local readonly vault_address="${3}"
  local readonly consul_prefix="${4}"
  local readonly user="${5}"

  if [[ "$server" == "true" ]]; then
    log_info "Generating Vault configuration for Nomad server"
    local allow_unauthenticated
    allow_unauthenticated=$(consul_kv "${consul_prefix}allow_unauthenticated")

    local nomad_cluster_role
    nomad_cluster_role=$(consul_kv "${consul_prefix}nomad_cluster_role")

    local nomad_server_role
    nomad_server_role=$(consul_kv "${consul_prefix}nomad_server_role")

    local vault_token
    vault_token=$(get_vault_token "${nomad_server_role}" "${vault_address}")

    local default_config=$(cat <<EOF
vault {
  enabled = true
  address = "$vault_address"
  token = "$vault_token"
  allow_unauthenticated = $allow_unauthenticated
  create_from_role = "$nomad_cluster_role"
}
EOF
)
  else
    log_info "Generating Vault configuration for Nomad client"

    local default_config=$(cat <<EOF
vault {
  enabled = true
  address = "$vault_address"
}
EOF
)
  fi

  log_info "Writing Vault configuration to ${config_dir}/vault.hcl"
  echo "${default_config}" > "${config_dir}/vault.hcl"
  chown "${user}:${user}" "${config_dir}/vault.hcl"
}

function generate_acl_config {
  local readonly config_dir="${1}"
  local readonly user="${2}"

  local default_config=$(cat <<EOF
acl {
  enabled = true
}
EOF
)

  log_info "Writing ACL configuration to ${config_dir}/acl.hcl"
  echo "${default_config}" > "${config_dir}/acl.hcl"
  chown "${user}:${user}" "${config_dir}/acl.hcl"
}

function generate_docker_config {
  local readonly consul_prefix="${1}"
  local readonly config_dir="${2}"
  local readonly user="${3}"
  local readonly consul_template_config="${4}"
  local readonly docker_auth_path="${5}"

  local docker_config=$(cat <<EOF
client {
  options {
    "docker.auth.config" = "${docker_auth_path}"
  }
}
EOF
)

  log_info "Writing Docker configuration to ${config_dir}/docker.hcl"
  echo "${docker_config}" > "${config_dir}/docker.hcl"
  chown "${user}:${user}" "${config_dir}/docker.hcl"

  local vault_path
  vault_path=$(consul_kv "${consul_prefix}docker-auth/path")

  local docker_template=$(cat <<EOF
template {
  destination = "${docker_auth_path}"
  create_dest_dirs = true

  # consul-template does not deal with ownership properly
  # See https://github.com/hashicorp/consul-template/issues/1061
  command = "bash -c 'chown ${user}:${user} ${docker_auth_path}'"

  perms = 0600
  error_on_missing_key = true

  # The goal is to produce something like
  # {
  #     "auths": {
  #         "registry.a.b": {
  #           "auth": "aaaaa="
  #         },
  #         "foo.bar.xyz": {
  #           "auth": "bbbb="
  #         }
  #     }
  # }
  #
  # But two things make it difficult:
  # 1. JSON doesn't do dangling commas
  # 2. Go Template has really basic logic handling
  #
  # Thus this template is more complicated than needed.
  contents = <<EOH
{{- define "keys" -}}
  {{- with secret "${vault_path}" }}
      {{- range \$key, \$value := .Data -}}
        {{ \$key }}{{ " " }}
      {{- end -}}
  {{- end -}}
{{- end -}}
{{- \$keys := (executeTemplate "keys" | trimSpace | split " ") -}}
{
    "auths": {
    {{- with secret "${vault_path}" -}}
    {{ \$auths := .Data }}
      {{- range \$i, \$key := \$keys }}
        {{- if \$i }},{{ end }}
        "{{ \$key }}": {
          "auth": "{{ index \$auths \$key }}"
        }
      {{- end }}
    {{- end }}
    }
}
EOH
}
EOF
)
  log_info "Writing Consul Template configuration to ${consul_template_config}/template_nomad_docker.hcl"
  echo "${docker_template}" > "${consul_template_config}/template_nomad_docker.hcl"
}

function generate_telemetry_conf {
  local readonly conf_file="${1}"
  local readonly user="${2}"
  local readonly server="${3}"
  local readonly statsd_addr="${4}"

  local telemetry_additional
  if [[ "$server" == "true" ]]; then
    telemetry_additional=$(cat <<EOF
  datadog_tags = ["_service:nomad_server"]
EOF
)
  else
    telemetry_additional=$(cat <<EOF
  datadog_tags = ["_service:nomad_client"]

  publish_allocation_metrics = true
  publish_node_metrics = true
EOF
)
  fi

  local telemetry_config=$(cat <<EOF
telemetry {
  datadog_address = "${statsd_addr}"
  disable_hostname = true
  ${telemetry_additional}
}
EOF
)

  log_info "Writing Telemetry Configuration for Nomad to ${conf_file}"
  echo "${telemetry_config}" > "${conf_file}"
  chown "${user}:${user}" "${conf_file}"
}

function generate_telegraf_procstat {
  local readonly telegraf_conf="${1}"
  local readonly pgrep_pattern="${2}"

  local procstat=$(cat <<EOF
# Monitor process cpu and memory usage
[[inputs.procstat]]
pattern = "${pgrep_pattern}"
EOF
)

  log_info "Writing Procstat Telemetry Configuration for Telegraf to ${telegraf_conf}"
  echo "${procstat}" > "${telegraf_conf}"
}

function main {
  local server="false"
  local client="false"
  local config_dir=""
  local vault_address="https://vault.service.consul:8200"
  local consul_prefix="terraform/"
  local user=""
  local consul_template_config="/opt/consul-template/config"
  local docker_auth=""
  local statsd_addr="127.0.0.1:8125"
  local telegraf_conf="/etc/telegraf/telegraf.d"
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
      --config-dir)
        assert_not_empty "$key" "$2"
        config_dir="$2"
        shift
      ;;
      --vault-address)
        assert_not_empty "$key" "$2"
        vault_address="$2"
        shift
        ;;
      --consul-prefix)
        assert_not_empty "$key" "$2"
        consul_prefix="$2"
        shift
        ;;
      --user)
        assert_not_empty "$key" "$2"
        user="$2"
        shift
        ;;
      --consul-template-config)
        assert_not_empty "$key" "$2"
        consul_template_config="$2"
        shift
        ;;
      --docker-auth)
        assert_not_empty "$key" "$2"
        docker_auth="$2"
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
  assert_is_installed "tr"
  assert_is_installed "jq"
  assert_is_installed "consul"

  wait_for_consul

  if [[ -z "$config_dir" ]]; then
    config_dir="$(cd "$SCRIPT_DIR/../config" && pwd)"
  fi

  if [[ -z "$docker_auth" ]]; then
    docker_auth="$(cd "$SCRIPT_DIR/.." && pwd)/docker.json"
  fi


  if [[ -z "$user" ]]; then
    user=$(get_owner_of_path "$config_dir")
  fi

  local vault_integration_enabled
  vault_integration_enabled=$(consul_kv_with_default "${consul_prefix}nomad-vault-integration/enabled" "no")
  if [[ "${vault_integration_enabled}" != "yes" ]]; then
    log_info "Nomad Vault integration is not enabled"
  else
    assert_is_installed "vault"
    generate_vault_config "${server}" "${config_dir}" "${vault_address}" "${consul_prefix}nomad-vault-integration/" "${user}"
  fi

  local acl_integration_enabled
  acl_integration_enabled=$(consul_kv_with_default "${consul_prefix}nomad-acl/enabled" "no")
  if [[ "${acl_integration_enabled}" != "yes" ]]; then
    log_info "Nomad ACL is not enabled"
  else
    generate_acl_config "${config_dir}" "${user}"
  fi

  local docker_auth_enabled
  docker_auth_enabled=$(consul_kv_with_default "${consul_prefix}docker-auth/enabled" "no")
  if [[ "${docker_auth_enabled}" != "yes" || "$server" == "true" ]]; then
    log_info "Docker authentication is not enabled or this is a Nomad server."
  else
    generate_docker_config "${consul_prefix}" "${config_dir}" "${user}" "${consul_template_config}" "${docker_auth}"
    supervisorctl signal SIGHUP consul-template
  fi

  local readonly telegraf_enabled

  if [[ "$server" == "true" ]]; then
    telegraf_enabled=$(consul_kv_with_default "${consul_prefix}telegraf/nomad_server/enabled" "no")
  else
    telegraf_enabled=$(consul_kv_with_default "${consul_prefix}telegraf/nomad_client/enabled" "no")
  fi

  if [[ "${telegraf_enabled}" != "yes" ]]; then
    log_info "Telegraf metrics is not enabled"
  else
    generate_telemetry_conf "${config_dir}/telemetry.hcl" "${user}" "${server}" "${statsd_addr}"
    generate_telegraf_procstat "${telegraf_conf}/procstat_nomad.conf" "^nomad\$"
  fi
}

main "$@"
