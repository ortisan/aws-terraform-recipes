resource "aws_api_gateway_rest_api" "finance_api" {

  name = "finance-api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "get_bitcoin" {
  path_part   = "bitcoin"
  parent_id   = aws_api_gateway_rest_api.finance_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.finance_api.id
}

resource "aws_api_gateway_method" "get_bitcoin" {
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  resource_id   = aws_api_gateway_resource.get_bitcoin.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_get_bitcoin_now" {
  rest_api_id             = aws_api_gateway_rest_api.finance_api.id
  resource_id             = aws_api_gateway_resource.get_bitcoin.id
  http_method             = aws_api_gateway_method.get_bitcoin.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.bitcoin_now_lambda.invoke_arn
}

# Lambda
resource "aws_lambda_permission" "allow_bitcoin_now_lambda_execution_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bitcoin_now_lambda.id
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.finance_api.id}/*/${aws_api_gateway_method.get_bitcoin.http_method}${aws_api_gateway_resource.get_bitcoin.path}"
}

resource "aws_api_gateway_deployment" "finance_api" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.get_bitcoin.id,
      aws_api_gateway_method.get_bitcoin.id,
      aws_api_gateway_integration.lambda_get_bitcoin_now.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.finance_api.id
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  stage_name    = "dev"
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.finance_api.id
  rest_api_id   = aws_api_gateway_rest_api.finance_api.id
  stage_name    = "prod"
}