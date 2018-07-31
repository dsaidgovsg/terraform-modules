# Lambda-API Gateway module

Deploys an aws lambda function from S3 zip file with an API Gateway trigger

# Usage

```
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
  subnet_id       = "yourSubnetID"
  security_group  = "yourSecurityGroupID"
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
```

# Pre-requisites

1. IAM role with basic lambda policy attached [Policy Template](https://docs.aws.amazon.com/lambda/latest/dg/policy-templates.html)
2. VPC, subnet_ and security group IDs (Already setup for use as this module does not create any networks)
3. S3 bucket containing function zip



