resource "aws_api_gateway_rest_api" "finance_api" {
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "finance-api"
      version = "1.0"
    }
    paths = {
      "/bitcoin" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "GET"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "https://ip-ranges.amazonaws.com/ip-ranges.json"
          }
        }
      },
      "/stocks" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "GET"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "https://ip-ranges.amazonaws.com/ip-ranges.json"
          }
        }
      }
    }
  })

  name = "finance-api"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "finance_api" {
  rest_api_id = aws_api_gateway_rest_api.finance_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.finance_api.body))
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