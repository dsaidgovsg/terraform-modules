#!/usr/bin/env python3

import argparse
from datetime import timedelta
import math
import os
import shutil
import subprocess
import sys
import time

#
# Constants
#

# ASG prefixes to grep
CONSUL_ASG = 'consul'
NOMAD_SERVER_ASG = 'nomad-server'
NOMAD_CLIENT_ASG = 'nomad-client'
VAULT_ASG = 'vault'

# Default addresses
CONSUL_ADDR = 'http://127.0.0.1:8500'
NOMAD_ADDR = 'http://127.0.0.1:4646'
VAULT_ADDR = 'https://127.0.0.1:8200'

# Interval of checking the change in set entries
CHECK_INTERVAL_SECS = 5

# Max time value to allow for ensuring both AWS and services have same set after killing
TIMEOUT_SECS = 300

# Commands to ensure to be available before starting
CMDS = [
    'aws',
    'consul',
    'nomad',
    'jq'
]

#
# Assertion commands
#


def assert_n_quorum(n):
    if n == 0:
        sys.exit('This process can only be run when there are 3 or more servers to maintain quorum.')


def assert_environ(env_name):
    env = os.environ.get(env_name)
    if not env:
        sys.exit('Require env var "{}" to be set!'.format(env_name))

    return env

def assert_cmds_exist(cmds):
    for cmd in cmds:
        if not shutil.which(cmd):
            sys.exit('Require command "{}"!'.format(cmd))


def assert_same_instances(aws_instances, service_nodes):
    if not aws_instances == service_nodes:
        sys.exit('AWS set of instances: "{}" is different from current set of service nodes: "{}"! Aborting...'
            .format(aws_instances, service_nodes))

#
# General
#

def unique(seq):
    # Inefficient but works
    # http://www.martinbroadhurst.com/removing-duplicates-from-a-list-while-preserving-order-in-python.html
    seen = set()
    return [x for x in seq if not (x in seen or seen.add(x))]


def find_n_to_kill_in_quorum(instances):
    # The number of instances left must be simple majority to maintain quorum
    # https://www.consul.io/docs/internals/consensus.html#deployment-table
    # Be careful with numeric operations in Python, since they are by default
    # interpreted as floating points operations
    return int(max(math.floor((len(instances) + 1) / 2) - 1, 0))


def invoke_shell(cmd):
    return subprocess.check_output(cmd, shell=True).decode('ascii').strip()


def get_auto_scaling_name(grep_name):
    try:
        return invoke_shell("""
        aws autoscaling describe-auto-scaling-groups | \
            jq --raw-output \
                '.AutoScalingGroups | .[].AutoScalingGroupName' | grep {}
        """.format(grep_name))
    except:
        raise AssertionError('"{}" prefixed ASG name does not exist!'.format(grep_name))


def get_instances_from_asg(asg_name):
    try:
        return set(invoke_shell("""
        aws autoscaling describe-auto-scaling-groups \
            --auto-scaling-group-name {} | \
            jq --raw-output '.AutoScalingGroups[0].Instances[].InstanceId'
        """.format(asg_name)).split())
    except:
        raise AssertionError('Cannot find instances from "{}" ASG!'.format(asg_name))


def kill_instance_from_asg(aws_instance):
    try:
        invoke_shell("""
        aws autoscaling terminate-instance-in-auto-scaling-group \
            --no-should-decrement-desired-capacity \
            --instance-id {}
        """.format(aws_instance))
    except:
        raise AssertionError('Unable to terminate AWS instance "{}" from its ASG!'
            .format(aws_instance))


def try_until_timeout(predicate, check_interval, timeout):
    elapsed_time = timedelta(seconds=0)

    while True:
        if predicate():
            return True

        if elapsed_time >= timeout:
            return False

        wait_secs = check_interval.total_seconds()
        print('> Waiting for {}s ({}s elapsed)'.format(wait_secs, elapsed_time.total_seconds()))
        time.sleep(wait_secs)
        elapsed_time += check_interval


def execute_kill_loop(kill_fn, asg_name, get_service_nodes_fn, n, check_interval, timeout):
    print("Killing {} instance(s) in one go...".format(n))

    orig_aws_instances = get_instances_from_asg(asg_name)
    instance_count = len(orig_aws_instances)

    for idx, orig_aws_instance in enumerate(orig_aws_instances):
        prev_aws_instances = get_instances_from_asg(asg_name)

        print('Killing instance "{} ({}/{})"...'.format(orig_aws_instance, idx + 1, instance_count))
        kill_fn(orig_aws_instance)

        # Check only after every N kills
        if (idx + 1) % n == 0 or (idx + 1) == instance_count:
            def predicate():
                curr_aws_instances = get_instances_from_asg(asg_name)
                curr_service_nodes = get_service_nodes_fn()

                # Cater for remaining instances when the count is less than N
                wait_n = min(instance_count - idx, n)

                return \
                    len(orig_aws_instances) == len(curr_aws_instances) and \
                    len(curr_aws_instances.difference(prev_aws_instances)) == wait_n and \
                    curr_aws_instances == curr_service_nodes

            print('KILL okay! Waiting for new instance(s) to spin up...')

            if not try_until_timeout(predicate, check_interval, timeout):
                raise AssertionError(
                    'New instance(s) is/are unable to join the service after timeout of {}s, aborting...'.format(timeout.total_seconds()))
            
            new_instances = get_instances_from_asg(asg_name).difference(prev_aws_instances)
            print('New instance(s) found: {}'.format(new_instances))

#
# Consul specifics
#

def list_consul_peers(address):
    try:
        return set(invoke_shell("""
        consul operator raft list-peers --http-addr {} | \
            grep -E i-[0-9a-f]+ | \
            cut -d " " -f 1
        """.format(address)).split())
    except:
        raise AssertionError('Unable to obtain peers from Consul operator raft list from "{}"!'
            .format(address))

#
# Nomad Server specifics
#

def list_nomad_server_members(address):
    try:
        return set(invoke_shell(r"""
        nomad server members -address {} | grep alive | sed -E 's/^(i-[0-9a-f]+)\..+$/\1/'
        """.format(address)).split())
    except:
        raise AssertionError('Unable to obtain Nomad Server members from "{}"!'
            .format(address))

#
# High level
#

def upgrade_consul(consul_asg, address, check_interval, timeout):
    print("Upgrading Consul instances...")
    consul_asg = get_auto_scaling_name(consul_asg)

    # Sanity check
    aws_instances = get_instances_from_asg(consul_asg)
    consul_nodes = list_consul_peers(address)
    print('AWS instances: {}'.format(aws_instances))
    print(' Consul nodes: {}'.format(consul_nodes))
    assert_same_instances(aws_instances, consul_nodes)

    n = find_n_to_kill_in_quorum(aws_instances)
    assert_n_quorum(n)
    
    execute_kill_loop(
        kill_instance_from_asg,
        consul_asg,
        lambda: list_consul_peers(address),
        n,
        check_interval,
        timeout)


def upgrade_nomad_server(nomad_server_asg, address, check_interval, timeout):
    print("Upgrading Nomad Servers instances...")
    nomad_server_asg = get_auto_scaling_name(nomad_server_asg)

    # Sanity check
    aws_instances = get_instances_from_asg(nomad_server_asg)
    nomad_servers = list_nomad_server_members(address)
    print('AWS instances: {}'.format(aws_instances))
    print('Nomad servers: {}'.format(nomad_servers))
    assert_same_instances(aws_instances, nomad_servers)

    n = find_n_to_kill_in_quorum(aws_instances)
    assert_n_quorum(n)
    
    execute_kill_loop(
        kill_instance_from_asg,
        nomad_server_asg,
        lambda: list_nomad_server_members(address),
        n,
        check_interval,
        timeout)


# TODO - Need to figure out how to properly wait for all upgradeed allocs get
#        reallocated first synchronously
# def upgrade_nomad_client(nomad_client_asg, address, check_interval, timeout):
#     nomad_client_asg = get_auto_scaling_name(nomad_client_asg)

# TODO - Need to make it such that we can place N unsealing keys into an env var
#        and let it automatically unseal using the env var iteratively
# def upgrade_vault(vault_asg, address, check_interval, timeout):
#     vault_asg = get_auto_scaling_name(vault_asg)

#
# Main
#

if __name__ == '__main__':
    parser = argparse.ArgumentParser('Script to upgrade service instances')

    # Dashes get converted into underscore when accessing the fields
    parser.add_argument('service', nargs='+', help='Service type to upgrade. consul | nomad-server | nomad-client | vault')

    parser.add_argument('--consul-asg', default=CONSUL_ASG, help='Simple grep pattern to get Consul ASG. Defaults to "{}".'.format(CONSUL_ASG))
    parser.add_argument('--consul-addr', default=CONSUL_ADDR, help='Consul server address to connect to. Defaults to "{}".'.format(CONSUL_ADDR))

    parser.add_argument('--nomad-server-asg', default=NOMAD_SERVER_ASG, help='Simple grep pattern to get Nomad Server ASG. Defaults to "{}".'.format(NOMAD_SERVER_ASG))
    parser.add_argument('--nomad-client-asg', default=NOMAD_CLIENT_ASG, help='Simple grep pattern to get Nomad Client ASG. Defaults to "{}".'.format(NOMAD_CLIENT_ASG))
    parser.add_argument('--nomad-addr', default=NOMAD_ADDR, help='Nomad Server address to connect to. Defaults to "{}".'.format(NOMAD_ADDR))

    parser.add_argument('--vault-asg', default=VAULT_ASG, help='Simple grep pattern to get Vault ASG. Defaults to "{}".'.format(VAULT_ASG))
    parser.add_argument('--vault-addr', default=VAULT_ADDR, help='Vault server address to connect to. Defaults to "{}".'.format(VAULT_ADDR))

    parser.add_argument('--check-interval', type=int, default=CHECK_INTERVAL_SECS, help='Interval of checking success for every upgrade step. Defaults to "{}" seconds.'.format(CHECK_INTERVAL_SECS))
    parser.add_argument('--timeout', type=int, default=TIMEOUT_SECS, help='Max time value to allow for ensuring consistency in upgrade after killing. Defaults to "{}" seconds.'.format(TIMEOUT_SECS))

    args = parser.parse_args()

    services = unique(args.service)
    check_interval = timedelta(seconds=args.check_interval)
    timeout = timedelta(seconds=args.timeout)

    print('Services to upgrade (in order): {}'.format(services))

    assert_cmds_exist(CMDS)

    for service in services:
        # All environment addresses should not contain trailing slash
        # e.g. http://consul.x.y OR https://consul.x.y
        if service == 'consul':
            upgrade_consul(args.consul_asg, args.consul_addr, check_interval, timeout)
            print('DONE Consul upgrading!')
        elif service == 'nomad-server':
            upgrade_nomad_server(args.nomad_server_asg, args.nomad_addr, check_interval, timeout)
            print('DONE Nomad Server upgrading!')
        elif service == 'nomad-client':
            # TODO
            # upgrade_nomad_client(args.nomad_client_asg, args.nomad_addr, check_interval, timeout)
            print('DONE Nomad Client upgrading!')
        elif service == 'vault':
            # TODO
            # upgrade_vault(args.vault_asg, args.vault_addr, check_interval, timeout)
            print('DONE Vault upgrading!')
        else:
            print('Ignoring unknown command "{}"'.format(service))
    
    print("DONE!")
