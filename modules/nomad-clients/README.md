# Nomad Clients

This module sets up an additional cluster of Nomad Clients after the initial cluster setup during
the bootstrap of the Core module.

You might want to deploy an additional Nomad Cluster with different instance types, configuration,
or just on different accounts for billing purposes.

## Core Integration

If you use the default `user_data` script (which is the same as the Core module) and the same Packer
template as the Core module, you will generally get the same set of integration.

For some other integrations listed below, you will have to define a new "server type" to enable
the integration. Refer to the documentation for additional information.

- [AWS Authentication](../aws-auth): This integration is required for many other integration.
- [`td-agent`](../td-agent)
- [Telegraf](../telegraf)
- [Vault SSH](../vault-ssh)

## Inputs and Outputs

Refer to [INOUT.md](INOUT.md)
