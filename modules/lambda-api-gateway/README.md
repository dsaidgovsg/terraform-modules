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

## Inputs and Outputs

Refer to [INOUT.md](INOUT.md)
