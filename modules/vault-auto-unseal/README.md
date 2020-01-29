# Vault Auto Unseal

Provisions additional resources to enable
[Vault Auto Unseal](https://www.vaultproject.io/docs/concepts/seal.html#auto-unseal) when used
with the Core module.

This module should be used in conjunction with the Core Module.

## Resources Provisioned

- A KMS Customer Managed Key (CMK)
- CMK policy to allow IAM control of access
- (Optional) VPC Endpoint for KMS and association with subnets

### VPC Endpoint

If you create a
[VPC Endpoint for KMS](https://docs.aws.amazon.com/kms/latest/developerguide/kms-vpc-endpoint.html),
all KMS API calls from Vault will not leave the AWS network.

You will need to provision the endpoints in the subnets that you want to run Vault in.
There are cases in some regions where the VPC Endpoint for KMS is not available in all the
availability zones (AZs). In these cases, the Autoscaling group provisioned in the Core module must
not be allowed to create instances in the unsupported AZs.

## Outputs to be fed to Core module

After including this module in your Terraform module, you should use the following output from this
module as inputs to the Core module.

- `kms_key_arn`: This output should be used in the input `vault_auto_unseal_kms_key_arn`

If you have enabled the VPC Endpoint:

- `vpce_kms_dns_name`: Use this in the input `vault_auto_unseal_kms_endpoint`
- `vpce_kms_subnets`: Use this in the input `vault_subnets`

## Inputs and Outputs

Refer to [INOUT.md](INOUT.md)
