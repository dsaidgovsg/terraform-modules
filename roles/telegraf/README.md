# telegraf

This role ensures that `telegraf` is installed on the target machine.

A [default configuration template](files/telegraf.conf) is copied to the AMI.
If you want to use your own configuration. you will have to provide the path to your configuration
file, given as a path to Ansible playbook variable `config_file`.

The default configuration will discard all metrics.

