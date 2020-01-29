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

## Inputs and Outputs

Refer to [INOUT.md](INOUT.md)
