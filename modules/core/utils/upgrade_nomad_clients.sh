#!/usr/bin/bash
set -euo pipefail

read -p 'AWS_PROFILE: ' awsProfile
read -p 'NOMAD_ADDR: ' nomadAddr
read -p 'NOMAD_TOKEN: ' nomadToken
read -p 'ASGName: ' ASGName

export AWS_PROFILE=$awsProfile
export NOMAD_ADDR=$nomadAddr
export NOMAD_TOKEN=$nomadToken

echo 'Getting old instance ID'
aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-name $ASGName \
    | jq --raw-output '.AutoScalingGroups[0].Instances[].InstanceId' \
    | tee instance-ids.txt

echo 'Getting AutoScalingGroups max-size and desired-capacity'
maxSize=$( aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-name $ASGName \
    | jq --raw-output '.AutoScalingGroups[0].MaxSize' )

desiredCapacity=$( aws autoscaling describe-auto-scaling-groups \
    --auto-scaling-group-name $ASGName \
    | jq --raw-output '.AutoScalingGroups[0].DesiredCapacity' )

echo 'Increasing AutoScalingGroups max-size and desired-capacity by 2'
newMaxSize=$(($maxSize*2))
newDesiredCapacity=$(($desiredCapacity*2))

echo "MaxSize = $newMaxSize"
echo "DesiredCapacity = $newDesiredCapacity"

echo 'Updating AutoScalingGroups'
aws autoscaling update-auto-scaling-group \
    --auto-scaling-group-name $ASGName \
    --max-size $newMaxSize \
    --desired-capacity $newDesiredCapacity

echo 'Checking if new nodes are ready'
nomad node status -json > nodes.json
count=$( tr ' ' '\n' < nodes.json | grep -c ready )
while [[ $count -lt $newDesiredCapacity ]]; do
  echo "Waiting, currently only $count nodes are ready"
  sleep 10 # can increase or decrease
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
while read a && read b <&3; do
  cont=true
  echo "Detaching instance-ids ${a}"
  while [ $cont != false ]; do
    errorMessage=$( aws autoscaling detach-instances --instance-ids ${p} \
      --auto-scaling-group-name $ASGName \
      --should-decrement-desired-capacity 2>&1 || echo $? )
    if echo $errorMessage | grep -q 'is not part of Auto Scaling group'; then
        cont=false
      echo "Detaching instance-ids ${a} completed"
      echo $errorMessage
    fi
    echo "Still detaching instance-ids ${a}"
    sleep 2
  done

  drain=true
  echo "Node drain for node-ids ${b}"
  while [ $drain != false ]; do
    if nomad node drain -enable -yes ${b} | grep -q 'drain complete' then
      drain=false
      echo "Node drain complete for node-ids ${b}"
    fi
    echo "Still draining node-ids ${b}"
    sleep 10
  done
done < instance-ids.txt 3<node-ids.txt

echo 'Terminating old instances'
aws ec2 terminate-instances \
    --instance-ids $(cat instance-ids.txt | tr '\n' ' ')
echo 'Termiation complete'

echo 'All operation complete'
echo 'Clearing tempt files'
rm instance-ids.txt nodes.json node-ids.txt

echo 'Clearing exported env variable'
unset AWS_PROFILE
unset NOMAD_ADDR
unset NOMAD_TOKEN