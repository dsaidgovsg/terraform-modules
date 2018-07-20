# Ansible CA Store

Ansible role to update the CA store of Debian based or Fedora based Linux machines with your custom
Certificate Authority.

This is based off the
[script](https://github.com/hashicorp/terraform-aws-vault/blob/master/modules/update-certificate-store/update-certificate-store) by HashiCorp.

## Usage

Include the role as you would do
[normally](https://docs.ansible.com/ansible/latest/user_guide/playbooks_roles.html#playbook-roles-and-include-statements).
The tasks in this role generally require privilege escalation with `become`.

### Variables

- `certificate`: Path to the certificate on the host machine.
- `certificate_rename`: File name to rename the certificate to on the target machine.
