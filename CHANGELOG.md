# CHANGELOG

## Unreleased

- Update Packer Templates to use `t3` instances
- Remove serf gossip rules from Core module (see [#153](https://github.com/GovTechSG/terraform-modules/pull/153))
- Fix `vault-pki` Ansible role conditional check for Consul integration failing when the integration does not exist
- Allow the `terraform` command to be replaced in Core's `vault-helper` script when something else like terragrunt is used
- Add more outputs to the `fluentd` module
