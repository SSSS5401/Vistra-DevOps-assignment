# S3 bucket for Lambda deployment packages with versioning enabled
resource "aws_s3_bucket" "bucket" {
  bucket = "vistra-lambda"
  tags   = local.common_tags
}

resource "aws_s3_bucket_versioning" "bucket_version" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
#########################################################################
# DynamoDB table for application data with encryption enabled
resource "aws_dynamodb_table" "dynamodb-table" {
  name         = "ApplicationData"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ItemId"

  attribute {
    name = "ItemId"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = local.common_tags
}
#########################################################################
# IAM roles for Lambda execution following least-privilege principles

data "aws_iam_policy_document" "assume_lambda_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "vistra-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda_role.json

  tags = local.common_tags
}

data "aws_iam_policy_document" "cloudwatch_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
        "arn:aws:logs:*:*:*"
    ]
  }
}

data "aws_iam_policy_document" "dynamodb_policy" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
    ]
    resources = [
        "arn:aws:dynamodb:*:*:table/ApplicationData"
    ]
  }
}

resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "vistra-lambda-cloudwatch-policy"
  description = ""
  policy      = data.aws_iam_policy_document.cloudwatch_policy.json

  tags = local.common_tags
}

resource "aws_iam_policy" "dynamodb_policy" {
  name        = "vistra-lambda-dynamodb-policy"
  description = ""
  policy      = data.aws_iam_policy_document.dynamodb_policy.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}
#########################################################################
# CloudWatch Log groups for structured logging

# resource "aws_cloudwatch_dashboard" "main" {
#   dashboard_name = "items-api-dashboard"
#   dashboard_body = jsonencode({
#     widgets = [
#       {
#         type   = "metric"
#         width  = 12
#         height = 6
#         properties = {
#           metrics = [
#             ["AWS/Lambda", "Errors", "FunctionName", var.lambda_function_name],
#             [".", "Duration", ".", "."],
#             [".", "Throttles", ".", "."]
#           ]
#           view    = "timeSeries"
#           stacked = false
#           region  = "us-east-1"
#           title   = "Lambda Metrics"
#         }
#       },
#       // Similar for API Gateway and DynamoDB
#     ]
#   })
# }

# resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
#   alarm_name          = "lambda-errors-high"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 1
#   metric_name         = "Errors"
#   namespace           = "AWS/Lambda"
#   period              = 60
#   statistic           = "Sum"
#   threshold           = 5
#   alarm_description   = "Alarm when Lambda errors exceed 5 in 1 min"
#   dimensions = {
#     FunctionName = var.lambda_function_name
#   }
# }
#########################################################################
# Lambda function for items API
data "archive_file" "lambda_handler_archive_file" {
  type        = "zip"
  source_dir  = "${path.module}/functions/items-api"
  output_path = "${path.module}/handler.zip"
}

resource "aws_s3_object" "lambda_handler_bucket_object" {
    bucket = aws_s3_bucket.bucket.id
    key    = "handler.zip"
    source = data.archive_file.lambda_handler_archive_file.output_path

    etag = filemd5(data.archive_file.lambda_handler_archive_file.output_path)

    depends_on = [
        data.archive_file.lambda_handler_archive_file,
    ]
}

resource "aws_lambda_function" "lambda_handler" {
    function_name    = "LambdaHandler"
    handler          = "index.handler" # Assuming Node.js with index.js and handler function
    runtime          = "nodejs22.x"
    role             = aws_iam_role.lambda_role.arn
    source_code_hash = filebase64sha256(data.archive_file.lambda_handler_archive_file.output_path) # Triggers update on code change

    s3_bucket = aws_s3_bucket.bucket.id
    s3_key    = aws_s3_object.lambda_handler_bucket_object.key

    depends_on = [
        aws_s3_object.lambda_handler_bucket_object,
    ]
}
#########################################################################
# API Gateway REST API with proxy integration
resource "aws_api_gateway_rest_api" "items_api" {
  name        = "items-api"
  description = ""

}

resource "aws_api_gateway_resource" "items" {
  rest_api_id = aws_api_gateway_rest_api.items_api.id
  parent_id   = aws_api_gateway_rest_api.items_api.root_resource_id
  path_part   = "items"
}

# GET method
resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.items_api.id
  resource_id   = aws_api_gateway_resource.items.id
  http_method   = "GET"
  authorization = "NONE"
}

# Lambda integration for GET
resource "aws_api_gateway_integration" "lambda_get" {
  rest_api_id = aws_api_gateway_rest_api.items_api.id
  resource_id = aws_api_gateway_resource.items.id
  http_method = aws_api_gateway_method.get.http_method

  integration_http_method = "GET"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.lambda_handler.invoke_arn
}