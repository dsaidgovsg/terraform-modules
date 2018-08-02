# Lambda-API Gateway module

This module deploys an aws lambda function from a S3 zip file with an API Gateway trigger attached.

### Basic Concepts

Lambda functions can be uploaded via a zip file so as to package dependencies in for runtime usage. Lambda allows retrieving the zip file from a S3 bucket, this module does not assist you in this step, you should have your own function uploaded to S3 using another method.

An API Gateway connects to the lambda function which allows for easy triggering of lambda, while securing the API with an API key so as to prevent unauthorized calls.

#### AWS Services this module deploys
  - Lambda
  - API Gateway

#### AWS Services this module requires
  - IAM
  - VPC
  - Security Groups
  - S3

# Pre-requisites

1. IAM role with basic lambda policy attached [Policy Template](https://docs.aws.amazon.com/lambda/latest/dg/policy-templates.html)
2. VPC, subnet_ and security group IDs (Already setup for use as this module does not create any networks)
3. S3 bucket containing a zipped file of the function and its dependencies

# Usage

```hcl
# main.tf
provider "aws" {
  region = "${var.aws_region}"
}

module "your_module" {
  source = "../modules/lambda-api-gateway"

  app_version     = "${var.app_version}"
  function_name   = "NameOfLambdaFunction"
  s3_key          = "xxx/${var.app_version}/function.zip"
  s3_bucket       = "mcf-lambda"
  iam_role_name   = "nameOfIAMRoleInAws"
  api_key_name    = "someNameForAPIKey"
  api_name        = "someNameForAPI"
  vpc_id          = "yourVPCID"
  subnet_id       = ["yourSubnetID","yourSubnetID2"]
  security_group  = ["yourSecurityGroupID"]
  runtime         = "nodejs8.10"

  environment = {
    NODE_ENV     = "production"
    IMAGE_NAME   = "${var.image_name}"
  }
}

variable "app_version" {
  default = "0.0.1"
}

variable "aws_region" {
  default = "ap-southeast-1"
}

variable "image_name" {
  default = "some_name"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| api_key_name | Name of API Key attached to API Gateway | string | - | yes |
| api_name | Name of the API to be added | string | - | yes |
| app_version | (Optional) Version of S3 function to use. Add this if you want to add a version number to the path of the application in S3 e.g. 0.0.1 | string | `` | no |
| environment | Environment variables passed into function when executing | map | - | yes |
| function_name | Name of lambda function in AWS | string | - | yes |
| iam_role_name | IAM Role Name that has policies attached to execute lambda functions | string | - | yes |
| lambda_handler_name | Name of the handler in lambda function e.g. main.handler | string | - | yes |
| lambda_timeout | Timeout afterwhich to kill the function | string | `10` | no |
| quota_limit | Maximum number of api calls for the usage plan | string | `100` | no |
| quota_period | Period in which the limit is accumulated, eg DAY, WEEK, MONTH | string | `DAY` | no |
| runtime | Lambda Runtime your function uses e.g. nodejs8.10 | string | - | yes |
| s3_bucket | S3 Bucket Name | string | - | yes |
| s3_key | Directory of the zip file inside the S3 bucket e.g. SomePath/${var.app_version}/function.zip | string | - | yes |
| security_group | List of security group to add to your function | list | - | yes |
| subnet_id | List of subnets to run your function in | list | - | yes |
| throttle_burst_limit | Burst token bucket | string | `5` | no |
| throttle_rate_limit | Rate at which burst tokens are added to bucket | string | `10` | no |
| vpc_id | VPC that your function will run in. Used when your function requires an internal IP for accessing internal services | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| api_base_url |  |
| api_id |  |
| api_stage_path |  |
| lambda_function-arn |  |


