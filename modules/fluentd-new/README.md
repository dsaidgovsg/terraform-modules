# Fluentd Server

This module sets up a Fluentd server which forwards logs from other modules to S3 and 
Elasticsearch.

## Packer Template

### Instance AMI

You will have to build an AMI with the [Packer template](packer/packer.json) provided.

```bash
packer build \
    -var-file "your_vars.json" \
    packer/ami/packer.json
```

Ansible will be used to provision the AMI.
