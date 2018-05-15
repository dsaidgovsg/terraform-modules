#!/usr/bin/bash
set -euo pipefail

# Note: This script works assuming you are using the default configuration where the node name is the instance ID.
# Below are the list of files that will be created when running the script:
# instance-ids.txt store all the instance-ids of the ASG
# nodes.json store the node infomation of all the nomad node, is use to get the node id of the nomad client
# node-ids.txt store the node id of those nomad client that will be drain

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly SLEEP_BETWEEN_RETRIES_SEC=10

function print_usage {
  echo
  echo "Usage: ./upgrade_nomad_clients.sh [asgName] [OPTIONS]"
  echo
  echo "This script is used to upgrade Nomad clients."
  echo
  echo "Options:"
  echo
  echo -e "  --asg-name\t\tSet the name of the AutoScalingGroups. Required!"
  echo -e "  --output-dir\t\tThe path to write the output files to. Optional. Default is the absolute path of './', relative to this script."
  echo -e "  --set-instance-ids\t\tTakes in a list of instance-id separated by 'space', instead of discovering them. Optional."
  echo -e "  --no-increase-asg-size\t\tFlag to prevent the script from increasing the ASG size. Optional. Default will increase the ASG max-size and desired-capacity by two-fold."
  echo -e "  --no-decrease-asg-desired-capacity\t\tFlag to prevent the script from decreasing the ASG size after detaching the instance from the ASG. Optional. Default will decrease the ASG desired-capacity everytime an instance has been detached."
  echo
  echo "Example:"
  echo
  echo "  ./upgrade_nomad_clients.sh --asg-name my-ASG --output-dir /tmp --set-instance-ids 'instance_id_1 instance_id_2'"
}

function assert_is_installed {
  local readonly name="$1"

  if [[ ! $(command -v ${name}) ]]; then
    echo "The binary '${name}' is required by this script but is not installed or in the system's PATH."
    exit 1
  fi
}

function assert_not_empty {
  local readonly arg_name="$1"
  local readonly arg_value="$2"

  if [[ -z "${arg_value}" ]]; then
    echo "The value for '${arg_name}' cannot be empty"
    print_usage
    exit 1
  fi
}

function increase_asg_size {
  local readonly asg_name="$1"
  echo 'Getting AutoScalingGroups max-size and desired-capacity'
  local readonly max_size=$( aws autoscaling describe-auto-scaling-groups \
      --auto-scaling-group-name $asg_name \
      | jq --raw-output '.AutoScalingGroups[0].MaxSize' )

  local readonly desired_capacity=$( aws autoscaling describe-auto-scaling-groups \
      --auto-scaling-group-name $asg_name \
      | jq --raw-output '.AutoScalingGroups[0].DesiredCapacity' )

  echo 'Increasing AutoScalingGroups max-size and desired-capacity by two-fold'
  local new_max_size=$(($max_size*2))
  local new_desired_capacity=$(($desired_capacity*2))

  echo "MaxSize = $new_max_size"
  echo "DesiredCapacity = $new_desired_capacity"

  echo 'Updating AutoScalingGroups'
  aws autoscaling update-auto-scaling-group \
      --auto-scaling-group-name $asg_name \
      --max-size $new_max_size \
      --desired-capacity $new_desired_capacity
}

function decrease_asg_max_size {
  local readonly asg_name="$1"
  echo 'Setting ASG_MAX_SIZE back to original value'
  readonly max_size=$( aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-name $asg_name \
  | jq --raw-output '.AutoScalingGroups[0].DesiredCapacity' )

  local new_max_size=$(($max_size/2))

  aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name $asg_name \
    --max-size $new_max_size
}

function auto_get_instance_ids {
  local readonly instance_ids_file="$1"
  echo 'Getting old instance ID'
  aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-name $asg_name \
    | jq --raw-output '.AutoScalingGroups[0].Instances[].InstanceId' \
    | tee $instance_ids_file
}

function manually_set_instance_ids {
  local readonly instance_ids="$1"
  local readonly instance_file="$2"
  echo "Manually set old instance ID to $instance_file"
  for id in $instance_ids
  do
    echo $id >> $instance_file
  done
}

output_dir=""
no_increase_asg_size="false"
instance_ids=""
asg_name=""
no_decrease_asg_desired_capacity="false"
while [[ $# > 0 ]]; do
  key="$1"

  case "$key" in
    --asg-name)
      assert_not_empty "$key" "$2"
      asg_name="$2"
      shift
    ;;
    --output-dir)
      assert_not_empty "$key" "$2"
      output_dir="$2"
      shift
    ;;
    --set-instance-ids)
      assert_not_empty "$key" "$2"
      instance_ids="$2"
      shift
    ;;
    --no-increase-asg-size)
      no_increase_asg_size="true"
    ;;
    --no-decrease-asg-desired-capacity)
      no_decrease_asg_desired_capacity="true"
    ;;
    *)
      echo "Unrecognized argument: $key"
      print_usage
      exit 1
      ;;
  esac

  shift
done

assert_is_installed "tr"
assert_is_installed "jq"

if [[ -z "$asg_name" ]]; then
  echo 'Error! AsgName not set!'
  print_usage
  exit 1
fi

if [[ -z "$output_dir" ]]; then
  output_dir="$(cd "$SCRIPT_DIR/" && pwd)"
fi

echo "Set files output dir to ${output_dir}"
readonly INSTANCE_IDS_FILE="${output_dir}/instance-ids.txt"
readonly NODES_JSON_FILE="${output_dir}/nodes.json"
readonly NODE_IDS_FILE="${output_dir}/node-ids.txt"

echo "INSTANCE_IDS_FILE: $INSTANCE_IDS_FILE"
echo "NODES_JSON_FILE: $NODES_JSON_FILE"
echo "NODE_IDS_FILE: $NODE_IDS_FILE"

if [[ -z "$instance_ids" ]]; then
  echo "Auto decovery of the instance ids"
  auto_get_instance_ids $INSTANCE_IDS_FILE
else
  echo "Manually set instance ids: $instance_ids"
  manually_set_instance_ids "$instance_ids" "$INSTANCE_IDS_FILE"
fi

if [ "$no_increase_asg_size" == "false" ]; then
  increase_asg_size $asg_name
fi

readonly desired_capacity=$( aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-name $asg_name \
  | jq --raw-output '.AutoScalingGroups[0].DesiredCapacity' )

echo 'Checking if new nodes are ready'
nomad node status -json > $NODES_JSON_FILE

count=0
while [[ $count -lt $desired_capacity ]]; do
  echo "Waiting, currently only $count nodes are ready"
  sleep "$SLEEP_BETWEEN_RETRIES_SEC"
  nomad node status -json > $NODES_JSON_FILE
  count=$( tr ' ' '\n' < $NODES_JSON_FILE | grep -c ready )
done

echo "All $count nodes are ready"
nomad node status

echo 'Getting node-ids of the old nodes'
while read instance_id; do
    jq --raw-output ".[] | select (.Name == \"${instance_id}\") | .ID" $NODES_JSON_FILE  >> $NODE_IDS_FILE
done < $INSTANCE_IDS_FILE

echo 'Setting old instances to retire'
while read node_id; do
  nomad node eligibility -disable "${node_id}"
done < $NODE_IDS_FILE

echo 'Draining old instances'
while read instance_id && read node_id <&3; do
  cont=true
  echo "Detaching instance-ids ${instance_id}"
  while [ $cont != false ]; do
    if [ $no_decrease_asg_desired_capacity == "false" ]; then
      error_message=$( aws autoscaling detach-instances --instance-ids ${instance_id} \
        --auto-scaling-group-name $asg_name \
        --should-decrement-desired-capacity 2>&1 || printf -- "$?" )
    else
      error_message=$( aws autoscaling detach-instances --instance-ids ${instance_id} \
        --auto-scaling-group-name $asg_name \
        --no-should-decrement-desired-capacity 2>&1 || printf -- "$?" )
    fi

    if jq -e . >/dev/null 2>&1 <<<"$error_message"; then
      echo "Still detaching instance-ids ${instance_id}"
      sleep "$SLEEP_BETWEEN_RETRIES_SEC"
    elif echo $error_message | grep -q 'is not in InService or Standby'; then
      echo "Still detaching instance-ids ${instance_id}"
      sleep "$SLEEP_BETWEEN_RETRIES_SEC"
    elif echo $error_message | grep -q 'is not part of Auto Scaling group'; then
      cont=false
      echo "Detaching instance-ids ${instance_id} completed"
      echo $error_message
    else
      echo "Other error encoutered!!!"
      echo $error_message
      exit 1
    fi
  done

  drain=true
  echo "Node drain for node-ids ${node_id}"
  while [ $drain != false ]; do
    if nomad node drain -enable -yes ${node_id} | grep -q "All allocations on node \"${node_id}\" have stopped"; then
      drain=false
      echo "Node drain complete for node-ids ${node_id}"
    else
      echo "Still draining node-ids ${node_id}"
      sleep "$SLEEP_BETWEEN_RETRIES_SEC"
    fi
  done

  echo "Terminating instance: $instance_id "
  aws ec2 terminate-instances \
    --instance-ids ${instance_id}
  echo 'Termiation complete'
done < $INSTANCE_IDS_FILE 3<$NODE_IDS_FILE

echo 'All operation complete'

if [ "$no_increase_asg_size" == "false" ]; then
  decrease_asg_max_size $asg_name
fi

echo 'Clearing tempt files'
rm $INSTANCE_IDS_FILE $NODES_JSON_FILE $NODE_IDS_FILE
