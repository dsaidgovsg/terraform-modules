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

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| enable_kms_vpce | Enable provisioning a VPC Endpoint for KMS | string | `false` | no |
| kms_key_alias | Alias to apply to the KMS key. Must begin with `alias/` | string | `alias/vault_auto_unseal` | no |
| tags | Tags to apply to resources that support it | string | `<map>` | no |
| vpc_id | ID of the VPC to provision the endpoints in | string | `` | no |
| vpce_sg_name | Name of the security group to provision for the KMS VPC Endpoint | string | `KMS VPC Endpoint` | no |
| vpce_subnets | List of subnets to provision the VPC Endpoint in. The Autoscaling group for Vault must be configured to use the same subnets that the VPC Endpoint are provisioned in. Note that because the KMS VPCE might not be supported in all the Availability Zones, you should use the output from the module to provide the list of subnets for your Vault ASG. | string | `<list>` | no |
| vpce_subnets_count | Number of subnets provided in `vpce_subnets` | string | `0` | no |

## Outputs

| Name | Description |
|------|-------------|
| kms_key_arn | ARN of the KMS CMK provisioned |
| vpce_kms_dns_name | DNS name for the KMS VPC Endpoint |
| vpce_kms_security_group | ID of the security group created for the VPC endpoint |
| vpce_kms_subnets | List of subnets where the KMS VPC Endpoint was provisioned |
