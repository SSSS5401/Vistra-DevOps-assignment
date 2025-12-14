# #########################################################################
locals {
  flattened_methods = flatten([
    for p in var.apigateway_setting.paths : [
      for m in p.methods : {
        path   = p.path
        method = m
        # lambda_function_arn = p.lambda_function_arn
        lambda_function_name = p.lambda_function_name
      }
    ]
  ])

  lambda_function_list = distinct([
    for p in var.apigateway_setting.paths : p.lambda_function_name
  ])
}

data "aws_lambda_function" "lambda_functions" {
  for_each = {
    for l in local.lambda_function_list : l => l
  }
  function_name = each.key
}

# API Gateway REST API with proxy integration
resource "aws_api_gateway_rest_api" "this" {
  name        = var.apigateway_name
  description = ""
  tags        = var.tags
}

resource "aws_api_gateway_resource" "path" {
  for_each = {
    for p in var.apigateway_setting.paths : p.path => p
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.value.path
}

# method
resource "aws_api_gateway_method" "path_method" {
  for_each = {
    for item in local.flattened_methods : "${item.path}.${item.method}" => item
  }

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.path[each.value.path].id
  http_method   = each.value.method
  authorization = "NONE" # Change to AWS_IAM, CUSTOM, etc. if needed
  # api_key_required = false  # Add if needed
}

# Lambda integration for methods
resource "aws_api_gateway_integration" "lambda" {
  for_each = {
    for item in local.flattened_methods : "${item.path}.${item.method}" => item
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_method.path_method[each.key].resource_id
  http_method = aws_api_gateway_method.path_method[each.key].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.lambda_functions[each.value.lambda_function_name].invoke_arn
}

# CORS support: add OPTIONS method + MOCK integration for each resource
resource "aws_api_gateway_method" "options" {
  for_each = aws_api_gateway_resource.path

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = each.value.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_integration" {
  for_each = aws_api_gateway_method.options

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }

  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_api_gateway_method_response" "options_response" {
  for_each = aws_api_gateway_method.options

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  for_each = aws_api_gateway_integration.options_integration

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = each.value.resource_id
  http_method = each.value.http_method
  status_code = "200"

  response_templates = {
    "application/json" = "{}"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  for_each = {
    for l in local.lambda_function_list : l => l
  }
  statement_id = "AllowAPIGatewayInvoke"
  action       = "lambda:InvokeFunction"
  #   function_name = aws_lambda_function.lambda_handler.function_name
  function_name = each.key
  principal     = "apigateway.amazonaws.com"

  # The /* part allows invocation from any stage, method and resource path
  # within API Gateway.
  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.options_integration,
  ]

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.path,
      aws_api_gateway_method.path_method,
      aws_api_gateway_integration.lambda,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "prod"

  tags = var.tags
}