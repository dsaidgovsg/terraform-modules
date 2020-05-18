#!/usr/bin/env bash
# This script is meant to be run in the User Data of each EC2 Instance while it's booting. The script uses the
# run-consul script to configure and start Consul in client mode and the run-nomad script to configure and start Nomad
# in client mode. Note that this script assumes it's running in an AMI built from the Packer template in
# examples/nomad-consul-ami/nomad-consul.json.

set -euo pipefail

# Avoid Terraform template by either using double dollar signs, or not using curly braces
readonly service_type="${service_type}"
readonly marker_path="/etc/user-data-marker"

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# These variables are passed in via Terraform template interplation
/opt/run-td-agent \
    --type "$service_type"

# Touch the marker file to indicate completion
touch "$marker_path"
