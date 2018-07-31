resource "aws_lambda_function" "lambda_function" {
  # (resource arguments)
  function_name = "${var.function_name}"
  s3_bucket     = "${var.s3_bucket}"
  s3_key        = "${var.s3_key}"
  handler       = "${var.lambda_handler_name}"
  runtime       = "${var.runtime}"
  timeout       = "${var.lambda_timeout}"

  role = "${data.aws_iam_role.lambda_role.arn}"

  vpc_config {
    subnet_ids         = ["${var.subnet_id}"]
    security_group_ids = ["${var.security_group}"]
  }

  environment {
    variables = "${var.environment}"
  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_function.arn}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.api-gateway-deployment.execution_arn}/*/*"
}

data "aws_iam_role" "lambda_role" {
  name = "${var.iam_role_name}"
}
