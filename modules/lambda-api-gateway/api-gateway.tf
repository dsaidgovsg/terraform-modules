resource "aws_api_gateway_api_key" "ApiKey" {
  name = var.api_key_name

  stage_key {
    rest_api_id = aws_api_gateway_rest_api.api-gateway.id
    stage_name  = aws_api_gateway_deployment.api-gateway-deployment.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "deploy-apigw-usage-plan-key" {
  key_id        = aws_api_gateway_api_key.ApiKey.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.deploy-api-gw-usage-plan.id
}

resource "aws_api_gateway_rest_api" "api-gateway" {
  name           = var.api_name
  api_key_source = "HEADER"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_rest_api.api-gateway.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id      = aws_api_gateway_rest_api.api-gateway.id
  resource_id      = aws_api_gateway_resource.proxy.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = "true"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id      = aws_api_gateway_rest_api.api-gateway.id
  resource_id      = aws_api_gateway_rest_api.api-gateway.root_resource_id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = "true"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda_function.invoke_arn
}

resource "aws_api_gateway_deployment" "api-gateway-deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  description       = "Deployed at ${timestamp()}"
  stage_description = timestamp() // forces to 'create' a new deployment each run
  rest_api_id       = aws_api_gateway_rest_api.api-gateway.id
  stage_name        = "api"
}

resource "aws_api_gateway_usage_plan" "deploy-api-gw-usage-plan" {
  name = var.api_name

  api_stages {
    api_id = aws_api_gateway_rest_api.api-gateway.id
    stage  = aws_api_gateway_deployment.api-gateway-deployment.stage_name
  }

  quota_settings {
    limit  = var.quota_limit
    period = var.quota_period
  }

  throttle_settings {
    burst_limit = var.throttle_burst_limit
    rate_limit  = var.throttle_rate_limit
  }
}
