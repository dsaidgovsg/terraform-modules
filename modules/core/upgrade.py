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

# Tag patterns to filter
CONSUL_TAG = 'consul'
NOMAD_SERVER_TAG = 'nomad-server'
NOMAD_CLIENT_TAG = 'nomad-client'
VAULT_TAG = 'vault'

# Default addresses
CONSUL_ADDR = 'http://127.0.0.1:8500'
NOMAD_ADDR = 'http://127.0.0.1:4646'
# VAULT_ADDR = 'https://127.0.0.1:8200'

# Interval of checking the change in set entries
CHECK_INTERVAL_SECS = 5

# Max time value to allow for ensuring both AWS and services have same set after killing
TIMEOUT_SECS = 300

# Default number of unseals required
VAULT_UNSEAL_COUNT = 3

# Commands to ensure to be available before starting
CMDS = [
    'aws',
    'consul',
    'curl',
    'nomad',
    'jq',
    'scp',
    'ssh'
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


def get_instance_ids_from_tag(tag_pattern):
    try:
        return set(invoke_shell("""
        aws ec2 describe-instances --filter \
            "Name=tag:Name,Values=*{}*" \
            "Name=instance-state-name,Values=running" | \
            jq --raw-output '.Reservations[].Instances[].InstanceId'
        """.format(tag_pattern)).split())
    except:
        raise AssertionError('Cannot find instance IDs with tag pattern "{}"!'.format(tag_pattern))


def get_instance_ip_addrs_from_tag(tag_pattern):
    try:
        return set(invoke_shell("""
        aws ec2 describe-instances --filter \
            "Name=tag:Name,Values=*{}*" \
            "Name=instance-state-name,Values=running" | \
            jq --raw-output '.Reservations[].Instances[].PrivateIpAddress'
        """.format(tag_pattern)).split())
    except:
        raise AssertionError('Cannot get instance IP addresses with tag pattern "{}"!'.format(tag_pattern))


def kill_instance(aws_instance):
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


def execute_kill_loop(kill_fn, tag_pattern, get_service_nodes_fn, n, check_interval, timeout):
    print("Killing {} instance(s) in one go...".format(n))

    orig_aws_instances = get_instance_ids_from_tag(tag_pattern)
    instance_count = len(orig_aws_instances)

    for idx, orig_aws_instance in enumerate(orig_aws_instances):
        prev_aws_instances = get_instance_ids_from_tag(tag_pattern)

        print('Killing instance "{} ({}/{})"...'.format(orig_aws_instance, idx + 1, instance_count))
        kill_fn(orig_aws_instance)

        # Check only after every N kills
        if (idx + 1) % n == 0 or (idx + 1) == instance_count:
            def predicate():
                curr_aws_instances = get_instance_ids_from_tag(tag_pattern)
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
            
            new_instances = get_instance_ids_from_tag(tag_pattern).difference(prev_aws_instances)
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
# Vault specifics
#

def list_vault_members():
    try:
        return set(invoke_shell("""
        curl -s https://consul.locus.rocks/v1/catalog/service/vault | jq --raw-output '.[].Node'
        """).split())
    except:
        raise AssertionError('Unable to obtain Vault members from Consul catalog!')


def send_ca_cert(username, ip_addr, local_ca_cert_path, remote_ca_cert_dir):
    try:
        local_ca_cert_name = os.path.basename(local_ca_cert_path)

        return invoke_shell("""
        scp -o StrictHostKeyChecking=no {lcertname} {user}@{addr}:/tmp && \
        ssh -o StrictHostKeyChecking=no {user}@{addr} "sudo mv /tmp/{lcertname} {rcertdir}"
        """.format(
            user=username,
            addr=ip_addr,
            lcertpath=local_ca_cert_path,
            certname=local_ca_cert_name,
            rcertdir=remote_ca_cert_dir))
    except:
        raise AssertionError('Unable to send CA certificate across to "{}"!'.format(ip_addr))


def unseal_vault(username, ip_addr, vault_local_ip_addr, unseal_key):
    try:
        return invoke_shell("""
        ssh -o StrictHostKeyChecking=no {user}@{addr} "vault operator unseal -address {local_addr} {unseal_key}"
        """.format(
            user=username,
            addr=ip_addr,
            local_addr=vault_local_ip_addr,
            unseal_key=unseal_key))
    except:
        raise AssertionError('Unable to send CA certificate across to "{}"!'.format(ip_addr))

#
# High level
#

def upgrade_consul(consul_tag_pattern, address, check_interval, timeout):
    print("Upgrading Consul instances...")

    # Sanity check
    aws_instances = get_instance_ids_from_tag(consul_tag_pattern)
    consul_nodes = list_consul_peers(address)
    print('AWS instances: {}'.format(aws_instances))
    print(' Consul nodes: {}'.format(consul_nodes))
    assert_same_instances(aws_instances, consul_nodes)

    n = find_n_to_kill_in_quorum(aws_instances)
    assert_n_quorum(n)
    
    execute_kill_loop(
        kill_instance,
        consul_tag_pattern,
        lambda: list_consul_peers(address),
        n,
        check_interval,
        timeout)


def upgrade_nomad_server(nomad_server_tag_pattern, address, check_interval, timeout):
    print("Upgrading Nomad Servers instances...")

    # Sanity check
    aws_instances = get_instance_ids_from_tag(nomad_server_tag_pattern)
    nomad_servers = list_nomad_server_members(address)
    print('AWS instances: {}'.format(aws_instances))
    print('Nomad servers: {}'.format(nomad_servers))
    assert_same_instances(aws_instances, nomad_servers)

    n = find_n_to_kill_in_quorum(aws_instances)
    assert_n_quorum(n)
    
    execute_kill_loop(
        kill_instance,
        nomad_server_tag_pattern,
        lambda: list_nomad_server_members(address),
        n,
        check_interval,
        timeout)


# TODO - Need to figure out how to properly wait for all upgradeed allocs get
#        reallocated first synchronously
# def upgrade_nomad_client(nomad_client_tag_pattern, address, check_interval, timeout):
#     pass

# TODO - Need to make it such that we can place N unsealing keys into an env var
#        and let it automatically unseal using the env var iteratively
def upgrade_vault(vault_tag_pattern, unseal_count, ca_cert_path, check_interval, timeout):
    print('Enter any {} Vault unseal key(s):'.format(unseal_count))

    unseal_keys = []
    for _ in range(0, unseal_count):
        unseal_keys.append(sys.stdin.readline().strip())

    aws_instances = get_instance_ids_from_tag(vault_tag_pattern)
    vault_servers = list_vault_members()
    print('AWS instances: {}'.format(aws_instances))
    print('Nomad servers: {}'.format(vault_servers))
    assert_same_instances(aws_instances, vault_servers)

    n = find_n_to_kill_in_quorum(aws_instances)
    assert_n_quorum(n)

#
# Main
#

if __name__ == '__main__':
    parser = argparse.ArgumentParser('Script to upgrade service instances')

    # Dashes get converted into underscore when accessing the fields
    parser.add_argument('service', nargs='+', help='Service type to upgrade. consul | nomad-server | nomad-client | vault')

    parser.add_argument('--consul-tag', default=CONSUL_TAG, help='Tag pattern of Consul instances. Defaults to "{}".'.format(CONSUL_TAG))
    parser.add_argument('--consul-addr', default=CONSUL_ADDR, help='Consul server address to connect to. Defaults to "{}".'.format(CONSUL_ADDR))

    parser.add_argument('--nomad-server-tag', default=NOMAD_SERVER_TAG, help='Tag pattern of Nomad Server instances. Defaults to "{}".'.format(NOMAD_SERVER_TAG))
    parser.add_argument('--nomad-client-tag', default=NOMAD_CLIENT_TAG, help='Tag pattern of Nomad Client instances. Defaults to "{}".'.format(NOMAD_CLIENT_TAG))
    parser.add_argument('--nomad-addr', default=NOMAD_ADDR, help='Nomad Server address to connect to. Defaults to "{}".'.format(NOMAD_ADDR))

    parser.add_argument('--vault-tag', default=VAULT_TAG, help='Tag pattern of Vault instances. Defaults to "{}".'.format(VAULT_TAG))
    parser.add_argument('--vault-unseal-count', type=int, default=VAULT_UNSEAL_COUNT, help='Number of unseal keys required to fully unseal a new Vault server')
    parser.add_argument('--vault-ca-cert', help='Path to CA certificate for unsealing')

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
            upgrade_consul(args.consul_tag, args.consul_addr, check_interval, timeout)
            print('DONE Consul upgrading!')
        elif service == 'nomad-server':
            upgrade_nomad_server(args.nomad_server_tag, args.nomad_addr, check_interval, timeout)
            print('DONE Nomad Server upgrading!')
        elif service == 'nomad-client':
            # TODO
            # upgrade_nomad_client(args.nomad_client_tag, args.nomad_addr, check_interval, timeout)
            print('DONE Nomad Client upgrading!')
        elif service == 'vault':
            # TODO
            upgrade_vault(args.vault_tag, args.vault_unseal_count, args.vault_ca_cert, check_interval, timeout)
            print('DONE Vault upgrading!')
        else:
            print('Ignoring unknown command "{}"'.format(service))
    
    print("DONE!")
