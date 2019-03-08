# AWS EC2 Container Registry Repository

Provides an EC2 Container Registry Repository.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_region | AWS Region to deploy to | string | `"ap-southeast-1"` | no |
| ecr\_name | Name of AWS EC2 Container Registry repository | string | `"locus"` | no |
| s3\_state\_bucket | S3 Bucket storing Terraform state | string | n/a | yes |
| tags | A map of tags to add to all resources | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | Full ARN of AWS EC2 Container Registry repository |
| name | Name of AWS EC2 Container Registry repository |
| registry\_id | The registry ID where the repository was created |
| repository\_url | The URL of the repository, in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName |
