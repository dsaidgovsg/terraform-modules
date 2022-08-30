## Providers

| Name | Version |
|------|---------|
| aws | >= 2.42, < 4.0.0 |
| consul | >= 2.5 |
| nomad | >= 1.4 |
| template | ~> 2.0 |
| vault | >= 3.8.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| additional\_blocks | Additional blocks to be added to the Jobspec | `string` | `""` | no |
| aws\_region | Region of AWS for which this is deployed | `string` | `"ap-southeast-1"` | no |
| consul\_key\_prefix | Path prefix to the key in Consul to set for the `core` module to know that this module has<br>        been applied. If you change this, you have to update the<br>        `integration_consul_prefix` variable in the core module as well. | `string` | `"terraform/"` | no |
| elasticsearch\_hostname | Host name of Elasticsearch | `any` | n/a | yes |
| elasticsearch\_port | Port number of Elasticsearch | `any` | n/a | yes |
| enable\_file\_logging | Enable logging to file on the Nomad jobs. Useful for debugging, but not really needed for production | `string` | `"false"` | no |
| es6\_support | Set to `true` if you are using Elasticsearch 6 and above to support the removal of mapping types (https://www.elastic.co/guide/en/elasticsearch/reference/current/removal-of-types.html) | `bool` | `false` | no |
| fluentd\_conf\_file | Rendered fluentd configuration file | `string` | `"alloc/config/fluent.conf"` | no |
| fluentd\_count | Number of copies of Fluentd to run | `number` | `3` | no |
| fluentd\_cpu | CPU resource assigned to the fluentd job | `number` | `3000` | no |
| fluentd\_force\_pull | Force pull an image. Useful if the tag is mutable. | `string` | `"false"` | no |
| fluentd\_image | Docker image for fluentd | `string` | `"govtechsg/fluentd-s3-elasticsearch"` | no |
| fluentd\_match | Tags that fluentd should output to S3 and Elasticsearch | `string` | `"@ERROR app.** docker.** services.** system.** vault**"` | no |
| fluentd\_memory | Memory resource assigned to the fluentd job | `number` | `512` | no |
| fluentd\_port | Port on the Docker image in which the TCP interface is exposed | `number` | `4224` | no |
| fluentd\_tag | Tag for fluentd Docker image | `string` | `"1.2.5-latest"` | no |
| inject\_source\_host | Inject the log source host name and address into the logs | `bool` | `true` | no |
| log\_vault\_policy | Name of the Vault policy to allow creating AWS credentials to write to Elasticsearch and S3 | `string` | `"fluentd_logger"` | no |
| log\_vault\_role | Name of the Vault role in the AWS secrets engine to provide credentials for fluentd to write to Elasticsearch and S3 | `string` | `"fluentd_logger"` | no |
| logs\_s3\_abort\_incomplete\_days | Specifies the number of days after initiating a multipart upload when the multipart upload must be completed. | `number` | `7` | no |
| logs\_s3\_bucket\_name | Name of S3 bucket to store logs for long term archival | `string` | `""` | no |
| logs\_s3\_enabled | Enable to log to S3 | `bool` | `true` | no |
| logs\_s3\_glacier\_transition\_days | Number of days before logs are transitioned to IA. Must be > var.logs\_s3\_ia\_transition\_days + 30 days | `number` | `365` | no |
| logs\_s3\_ia\_transition\_days | Number of days before logs are transitioned to IA. Must be > 30 days | `number` | `90` | no |
| logs\_s3\_policy | Name of the IAM policy to provision for write access to the bucket | `string` | `"LogsS3Write"` | no |
| logs\_s3\_storage\_class | Default storage class to store logs in S3. Choose from `STANDARD`, `REDUCED_REDUNDANCY` or `STANDARD_IA` | `string` | `"STANDARD"` | no |
| node\_class | Node class for Nomad clients to constraint the jobs to. Use this with `node_class_operator`. The default matches everything. | `string` | `".?"` | no |
| node\_class\_operator | Nomad constrant operator (https://www.nomadproject.io/docs/job-specification/constraint.html#operator) to use for restricting Nomad clients node class. Use this with `node_class`. The default matches everything. | `string` | `"regexp"` | no |
| nomad\_azs | AZs which Nomad is deployed to. If left empty, the list of AZs from this region will be used | `list(string)` | `[]` | no |
| source\_address\_key | Key to inject the source address to | `string` | `"host"` | no |
| source\_hostname\_key | Key to inject the source hostname to | `string` | `"hostname"` | no |
| tags | Tags to apply to resources | `map` | <pre>{<br>  "Terraform": "true"<br>}<br></pre> | no |
| vault\_address | Vault server address for custom execution of commands, required if `vault_sts_iam_permissions_boundary` is set | `string` | `""` | no |
| vault\_sts\_iam\_permissions\_boundary | Optional IAM policy as permissions boundary for STS generated IAM user | `string` | n/a | yes |
| vault\_sts\_path | If logging to S3 is enabled, provide to the path in Vault in which the AWS Secrets Engine is mounted | `string` | `""` | no |
| weekly\_index\_enabled | Enable weekly indexing strategy for Fluentd Elasticsearch plugin. If disabled, default indexing strategy is daily. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| jobspec | Rendered jobspec |
| s3\_arn | ARN of the S3 bucket created |
| s3\_iam\_arn | ARN of the IAM Policy document for S3 access |

