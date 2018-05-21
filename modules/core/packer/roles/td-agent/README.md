# td-agent (fluentd)

This role ensures that `td-agent` is installed on the target machine.

You are required to provide your own configuration for `td-agent`, given as a path to Ansible
playbook variable `config_file`.

See <https://www.fluentd.org/faqs> to check the difference between `td-agent`
and `fluentd`.
