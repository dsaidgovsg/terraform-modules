variable "app_version" {} #0.0.1
variable "function_name" {}
variable "lambda_handler_name" {} #your-function.handler
variable "runtime" {} # nodejs8.10
variable "s3_key" {} # SomePath/${var.app_version}/function.zip
variable "s3_bucket" {}
variable "iam_role_name" {}
variable "api_key_name" {}
variable "api_name" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "security_group" {}

variable "environment" {
  type = "map"
}

variable "lambda_timeout" {
  default = "10"
}
