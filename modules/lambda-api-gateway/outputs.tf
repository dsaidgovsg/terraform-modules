output "lambda_function-arn" {
  value = aws_lambda_function.lambda_function.arn
}

output "api_id" {
  value = aws_api_gateway_rest_api.api-gateway.id
}

output "api_base_url" {
  value = aws_api_gateway_deployment.api-gateway-deployment.invoke_url
}

output "api_stage_path" {
  value = aws_api_gateway_deployment.api-gateway-deployment.stage_name
}
