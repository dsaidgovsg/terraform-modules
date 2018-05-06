#!/usr/bin/bash
set -euo pipefail

# Note: This script works assuming you are using the default configuration where the node name is the instance ID.
# Below are the list of files that will be created when running the script:
# instance-ids.txt store all the instance-ids of the ASG
# nodes.json store the node infomation of all the nomad node, is use to get the node id of the nomad client
# node-ids.txt store the node id of those nomad client that will be drain

readonly ASG_NAME="$1"
readonly SLEEP_BETWEEN_RETRIES_SEC=10

echo 'Getting old instance ID'
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-name $ASG_NAME \
    | jq --raw-output '.AutoScalingGroups[0].Instances[].InstanceId' \
    | tee instance-ids.txt

echo 'Getting AutoScalingGroups max-size and desired-capacity'
maxSize=$( aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-name $ASG_NAME \
    | jq --raw-output '.AutoScalingGroups[0].MaxSize' )

desiredCapacity=$( aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-name $ASG_NAME \
    | jq --raw-output '.AutoScalingGroups[0].DesiredCapacity' )

echo 'Increasing AutoScalingGroups max-size and desired-capacity by two-fold'
newMaxSize=$(($maxSize*2))
newDesiredCapacity=$(($desiredCapacity*2))

echo "MaxSize = $newMaxSize"
echo "DesiredCapacity = $newDesiredCapacity"

echo 'Updating AutoScalingGroups'
aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name $ASG_NAME \
    --max-size $newMaxSize \
    --desired-capacity $newDesiredCapacity

echo 'Checking if new nodes are ready'
nomad node status -json > nodes.json
count=0
while [[ $count -lt $newDesiredCapacity ]]; do
  echo "Waiting, currently only $count nodes are ready"
  sleep "$SLEEP_BETWEEN_RETRIES_SEC"
  nomad node status -json > nodes.json
  count=$( tr ' ' '\n' < nodes.json | grep -c ready )
done

echo "All $count nodes are ready"
nomad node status

echo 'Getting node-ids of the old nodes'
while read p; do
    jq --raw-output ".[] | select (.Name == \"${p}\") | .ID" nodes.json  >> node-ids.txt
done < instance-ids.txt

echo 'Setting old instances to retire'
while read p; do
  nomad node eligibility -disable "${p}"
done < node-ids.txt

echo 'Draining old instances'
while read instance_id && read node_id <&3; do
  cont=true
  echo "Detaching instance-ids ${instance_id}"
  while [ $cont != false ]; do
    errorMessage=$( aws autoscaling detach-instances --instance-ids ${p} \
      --auto-scaling-group-name $ASG_NAME \
      --should-decrement-desired-capacity 2>&1 || echo $? )
    if echo $errorMessage | grep -q 'is not part of Auto Scaling group'; then
      cont=false
      echo "Detaching instance-ids ${instance_id} completed"
      echo $errorMessage
    fi
    echo "Still detaching instance-ids ${instance_id}"
    sleep "$SLEEP_BETWEEN_RETRIES_SEC"
  done

  drain=true
  echo "Node drain for node-ids ${node_id}"
  while [ $drain != false ]; do
    if nomad node drain -enable -yes ${node_id} | grep -q 'drain complete' then
      drain=false
      echo "Node drain complete for node-ids ${node_id}"
    fi
    echo "Still draining node-ids ${node_id}"
    sleep "$SLEEP_BETWEEN_RETRIES_SEC"
  done

  echo "Terminating instance: $instance_id "
    aws ec2 terminate-instances \
        --instance-ids ${instance_id}
    echo 'Termiation complete'
done < instance-ids.txt 3<node-ids.txt

echo 'All operation complete'
echo 'Clearing tempt files'
rm instance-ids.txt nodes.json node-ids.txt

echo 'Clearing exported env variable'

