## Providers

| Name | Version |
|------|---------|
| aws | >= 2.42, < 4.0.0 |
| local | n/a |
| template | ~> 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| artifacts\_base\_path | Base path to output file artifacts. Use `get_terragrunt_dir()` with an `extra_argument` to provide this value | `string` | `"./"` | no |
| elasticsearch\_host | Elasticsearch endpoint used to submit index, search, and data upload requests | `any` | n/a | yes |
| elasticsearch\_port | Elasticsearch service port | `any` | n/a | yes |
| fluentd\_match | Tags that fluentd should output to S3 and Elasticsearch | `any` | n/a | yes |
| fluentd\_port | Port on the Docker image in which the HTTP interface is exposed | `number` | `4224` | no |
| logs\_local\_store\_enabled | Enable to store copy of logs on the local machine | `bool` | `false` | no |
| logs\_s3\_abort\_incomplete\_days | Specifies the number of days after initiating a multipart upload when the multipart upload must be completed. | `number` | `7` | no |
| logs\_s3\_bucket\_name | Name of S3 bucket to store logs for long term archival | `any` | n/a | yes |
| logs\_s3\_enabled | Enable to log to S3 | `bool` | `true` | no |
| logs\_s3\_glacier\_transition\_days | Number of days before logs are transitioned to IA. Must be > var.logs\_s3\_ia\_transition\_days + 30 days | `number` | `365` | no |
| logs\_s3\_ia\_transition\_days | Number of days before logs are transitioned to IA. Must be > 30 days | `number` | `90` | no |
| logs\_s3\_policy | Name of the IAM policy to provision for write access to the bucket | `string` | `"LogsS3WriteNew"` | no |
| logs\_s3\_storage\_class | Default storage class to store logs in S3. Choose from `STANDARD`, `REDUCED_REDUNDANCY` or `STANDARD_IA` | `string` | `"STANDARD"` | no |
| tags | Tags to apply to resources | `map` | <pre>{<br>  "Terraform": "true"<br>}<br></pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| s3\_policy\_arn | n/a |

