# telegraf

This role ensures that `telegraf` is installed on the target machine.

You are required to provide your own configuration for `telegraf`, given as a path to Ansible
playbook variable `config_file`. Note that `config_file` is copied into `config_dest_file` by an
Ansible template copy, and the var file can be optionally provided to `config_vars_file` for the
template copy.
