# Amazon Linux Ansible Roles

Contains Ansible playbook roles for installation of services on Amazon Linux
based AMI, which is useful when setting up custom AMI for
[AWS EMR](https://aws.amazon.com/emr/), which only accept Amazon Linux based AMI
at the moment.

This is mirrors some of the Ansible playbooks in [core](../core/packer/roles)
and converts some tasks that are specific to Ubuntu / `apt` into Amazon Linux /
`yum` ones.

## How to use

For [`packer`](https://www.packer.io/), assuming your current set-up already
uses Ansible playbook as one of the `provisioners` to build the custom AMI, to
include installation of `consul` into the image, add the following playbook
configuration value as one of your `tasks`:

```yml
- name: Install Consul
  include_role:
    name: "{{ path_to_dir_before_submod }}/terraform-modules/modules/amazon-linux/packer/roles/consul"
- name: Install Consul-Template
  include_role:
    name: "{{ path_to_dir_before_submod }}/terraform-modules/modules/amazon-linux/packer/roles/install-consul-template"
```

The above also assumes that `terraform-modules` is a submodule within your
main repository.

## How to get Consul agent running

For Amazon Linux based AMI, one of the ways to get `consul` running is to add
the line to start it under `/etc/rc.local`. The below example (Ansible playbook
for `packer`) demonstrates adding a line to start `consul` in `rc.local`, with
some commonly used parameters.

```yml
- name: Set Consul agent to run at startup
  lineinfile:
    path: /etc/rc.local
    line: "/opt/consul/bin/run-consul --client --cluster-tag-key {{ cluster_tag_key }} --cluster-tag-value {{ cluster_tag_value }}"
    state: present
  become: yes
```

Starting / rebooting the instance using the custom AMI with all the above items
should get it working / very close to working, allowing it to communicate with
`consul` servers.

## Consul Template setup for Vault token retrival and renewal

This setup follows the implementation in [aws-auth](../aws-auth). It is modified
to use the [`upstart`](http://upstart.ubuntu.com/) daemon so it can work with
Amazon Linux.
