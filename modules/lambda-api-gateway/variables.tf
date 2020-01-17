variable "app_version" {
  description = "(Optional) Version of S3 function to use. Add this if you want to add a version number to the path of the application in S3 e.g. 0.0.1"
  default     = ""
}

variable "function_name" {
  description = "Name of lambda function in AWS"
}

variable "lambda_handler_name" {
  description = "Name of the handler in lambda function e.g. main.handler"
}

variable "runtime" {
  description = "Lambda Runtime your function uses e.g. nodejs8.10"
}

variable "s3_key" {
  description = "Directory of the zip file inside the S3 bucket e.g. SomePath/$${var.app_version}/function.zip"
}

variable "s3_bucket" {
  description = "S3 Bucket Name"
}

variable "iam_role_name" {
  description = "IAM Role Name that has policies attached to execute lambda functions"
}

variable "api_key_name" {
  description = "Name of API Key attached to API Gateway"
}

variable "api_name" {
  description = "Name of the API to be added"
}

variable "vpc_id" {
  description = "VPC that your function will run in. Used when your function requires an internal IP for accessing internal services"
}

variable "subnet_id" {
  description = "List of subnets to run your function in"
  type        = list(string)
}

variable "security_group" {
  description = "List of security group to add to your function"
  type        = list(string)
}

variable "environment" {
  description = "Environment variables passed into function when executing"
  type        = map(string)
}

variable "lambda_timeout" {
  description = "Timeout afterwhich to kill the function"
  default     = "10"
}

variable "quota_limit" {
  description = "Maximum number of api calls for the usage plan"
  default     = 100
}

variable "quota_period" {
  description = "Period in which the limit is accumulated, eg DAY, WEEK, MONTH"
  default     = "DAY"
}

variable "throttle_burst_limit" {
  description = "Burst token bucket"
  default     = 5
}

variable "throttle_rate_limit" {
  description = "Rate at which burst tokens are added to bucket"
  default     = 10
}
