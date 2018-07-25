# telegraf

This role ensures that `telegraf` is installed on the target machine.

A [default configuration template](files/telegraf.conf.template] is copied to the AMI.
If you want to use your own configuration. you are required to provide your own configuration for
`telegraf`, given as a path to Ansible playbook variable `config_file`.

The default configuration will log metrics to the Elasticsearch service provisioned by the
`elasticsearch` module.

Note that `config_file` is copied into `config_dest_file` by an Ansible template copy,
and a custom var file can be optionally provided to `config_vars_file` for the template copy.
