# AWS EFS

This module creates AWS EFS to be available for services that require persistent
storage.

When encryption is enabled for EFS (which is the default), this module will
generate a new custom KMS key for this purpose.

## Nomad job instruction on mounting

To mount EFS into one of the Nomad job running Docker, the Nomad jobspec should
look something like the following:

```hcl
job "xxx" {
  group "xxx" {
    task "xxx" {
      config = {
        image = "xxx"

        mounts = [
          {
            source   = "${efs_id}/"
            target   = "/mnt/whatever/dir/name/you/want"
            readonly = false

            volume_options {
              driver_config {
                name = "efs"
              }
            }
          },
        ]

        # Required for mount --bind
        privileged = true

        ...
      }
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allowed\_cidr\_blocks | CIDR blocks to allow EFS port access into the security group | list | n/a | yes |
| efs\_ports | Ports to allow access to EFS | map | `<map>` | no |
| enable\_encryption | Boolean to specify whether to enable KMS encryption for EFS | string | `"true"` | no |
| kms\_additional\_tags | KMS key additional tags for EFS | map | `<map>` | no |
| kms\_key\_alias | Alias for the KMS key for EFS. Must prefix with alias/. Overrides kms_key_alias_prefix if this is specified. | string | `""` | no |
| kms\_key\_alias\_prefix | Alias prefix for the KMS key for EFS. Current timestamp is used as the suffix. Must prefix with alias/. kms_key_alias is used instead if specified. | string | `"alias/efs-default-"` | no |
| kms\_key\_deletion\_window\_in\_days | Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days | string | `"30"` | no |
| kms\_key\_description | Description to use for KMS key | string | `"Encryption key for EFS"` | no |
| kms\_key\_enable\_rotation | Specifies whether key rotation is enabled | string | `"true"` | no |
| kms\_key\_policy\_json | JSON content of IAM policy to attach to the KMS key. Empty string to use root identifier as principal for all KMS actions. | string | `""` | no |
| security\_group\_description | Description of security group for EFS | string | `"Security group for EFS"` | no |
| security\_group\_name | Name of security group for EFS. Empty string to use a random name. | string | `""` | no |
| tags | Tags to apply to resources that allow it | map | `<map>` | no |
| vpc\_id | ID of VPC to add the security group for the EFS setup | string | n/a | yes |
| vpc\_subnets | IDs of VPC subnets to add the mount targets in | list | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| arn | ARN of EFS |
| dns\_name | DNS name of EFS |
| id | ID of EFS |
| kms\_key\_alias | KMS key alias used for EFS encryption |
| kms\_key\_arn | ARN of KMS key used for EFS encryption |
| kms\_key\_key\_id | Key ID of KMS key used for EFS encryption |
| mount\_target\_dns\_names | Mount target DNS names of EFS. The order of elements is the same as the order of the given vpc_subnets. |
| mount\_target\_ids | Mount target IDs of EFS. The order of elements is the same as the order of the given vpc_subnets. |
| root\_resource | ARN of EFS resource at root |
| security\_group\_arn | ARN of the EFS security group |
| security\_group\_id | ID of the EFS security group |
| security\_group\_name | Name of the EFS security group |
