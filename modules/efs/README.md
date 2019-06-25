# AWS EFS

This module creates AWS EFS to be available for services that require persistent
storage.

## Nomad job instruction on mounting

To mount EFS into one of the Nomad job running Docker, the Nomad jobspec should
look something like the following:

```hcl
job "xxx" {
  group "xxx" {
    task "xxx" {
      config {
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
| efs\_ports | Ports to allow access to EFS | map | `<map>` | no |
| kms\_additional\_tags | KMS key additional tags for EFS | map | `<map>` | no |
| kms\_key\_alias | Alias for the KMS key for EFS. Must prefix with alias/. Overrides kms_key_alias_prefix if this is specified. | string | `""` | no |
| kms\_key\_alias\_prefix | Alias prefix for the KMS key for EFS. Current timestamp is used as the suffix. Must prefix with alias/. kms_key_alias is used instead if specified. | string | `"alias/efs-default-"` | no |
| security\_group\_name | Name of security group for EFS. Empty string to use a random name. | string | `""` | no |
| tags | Tags to apply to resources that allow it | map | `<map>` | no |
| vpc\_id | ID of VPC to add the security group for the EFS setup | string | n/a | yes |
| vpc\_subnets | IDs of VPC subnets to add the mount targets in | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| dns\_name | DNS name of EFS |
| id | ID of the setup EFS |
| kms\_key\_alias | KMS key alias used for encryption |
| root\_resource | ARN of EFS resource at root |
