## Providers

| Name | Version |
|------|---------|
| aws | >= 2.42 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| api\_key\_name | Name of API Key attached to API Gateway | `any` | n/a | yes |
| api\_name | Name of the API to be added | `any` | n/a | yes |
| app\_version | (Optional) Version of S3 function to use. Add this if you want to add a version number to the path of the application in S3 e.g. 0.0.1 | `string` | `""` | no |
| environment | Environment variables passed into function when executing | `map(string)` | n/a | yes |
| function\_name | Name of lambda function in AWS | `any` | n/a | yes |
| iam\_role\_name | IAM Role Name that has policies attached to execute lambda functions | `any` | n/a | yes |
| lambda\_handler\_name | Name of the handler in lambda function e.g. main.handler | `any` | n/a | yes |
| lambda\_timeout | Timeout afterwhich to kill the function | `string` | `"10"` | no |
| quota\_limit | Maximum number of api calls for the usage plan | `number` | `100` | no |
| quota\_period | Period in which the limit is accumulated, eg DAY, WEEK, MONTH | `string` | `"DAY"` | no |
| runtime | Lambda Runtime your function uses e.g. nodejs8.10 | `any` | n/a | yes |
| s3\_bucket | S3 Bucket Name | `any` | n/a | yes |
| s3\_key | Directory of the zip file inside the S3 bucket e.g. SomePath/${var.app\_version}/function.zip | `any` | n/a | yes |
| security\_group | List of security group to add to your function | `list(string)` | n/a | yes |
| subnet\_id | List of subnets to run your function in | `list(string)` | n/a | yes |
| throttle\_burst\_limit | Burst token bucket | `number` | `5` | no |
| throttle\_rate\_limit | Rate at which burst tokens are added to bucket | `number` | `10` | no |
| vpc\_id | VPC that your function will run in. Used when your function requires an internal IP for accessing internal services | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| api\_base\_url | n/a |
| api\_id | n/a |
| api\_stage\_path | n/a |
| lambda\_function-arn | n/a |

