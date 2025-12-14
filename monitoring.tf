locals {
  lambda_name = split(":", module.lambda.lambda_function_arn)[length(split(":", module.lambda.lambda_function_arn)) - 1]
}

# CloudWatch Log Metric Filter for Lambda ERROR logs (structured JSON: {"level":"ERROR"})
resource "aws_cloudwatch_log_metric_filter" "lambda_error_filter" {
  name           = "lambda-error-filter"
  log_group_name = aws_cloudwatch_log_group.this.name
  pattern        = "{ $.level = \"ERROR\" }"

  metric_transformation {
    name      = "ErrorsFromLogs"
    namespace = "LambdaLogs"
    value     = "1"
  }
}

# Alarm: Lambda Errors (metric)
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.app_name}-lambda-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = var.lambda_error_threshold
  dimensions = {
    FunctionName = local.lambda_name
  }
}

# Alarm: Lambda Duration (average)
resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${var.app_name}-lambda-duration-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Average"
  threshold           = var.lambda_duration_threshold_ms
  dimensions = {
    FunctionName = local.lambda_name
  }
}

# Alarm: Lambda Throttles
resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  alarm_name          = "${var.app_name}-lambda-throttles"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = var.lambda_throttle_threshold
  dimensions = {
    FunctionName = local.lambda_name
  }
}

# Alarm: API Gateway 5XX errors
resource "aws_cloudwatch_metric_alarm" "apigw_5xx" {
  alarm_name          = "${var.app_name}-apigw-5xx"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = 60
  statistic           = "Sum"
  threshold           = var.api_5xx_threshold
  dimensions = {
    ApiId = module.apigateway.rest_api_id
    Stage = "prod"
  }
}

# Alarm: API Gateway Latency
resource "aws_cloudwatch_metric_alarm" "apigw_latency" {
  alarm_name          = "${var.app_name}-apigw-latency-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Latency"
  namespace           = "AWS/ApiGateway"
  period              = 60
  statistic           = "Average"
  threshold           = var.api_latency_threshold_ms
  dimensions = {
    ApiId = module.apigateway.rest_api_id
    Stage = "prod"
  }
}

# Alarm: DynamoDB ThrottledRequests
resource "aws_cloudwatch_metric_alarm" "dynamodb_throttles" {
  alarm_name          = "${var.app_name}-dynamodb-throttles"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = 60
  statistic           = "Sum"
  threshold           = var.dynamodb_throttle_threshold
  dimensions = {
    TableName = module.dynamodb.table_name
  }
}

# CloudWatch Dashboard combining key widgets
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.app_name}-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 24
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", local.lambda_name],
            ["AWS/Lambda", "Duration", "FunctionName", local.lambda_name, { "stat" : "Average" }],
            ["AWS/Lambda", "Throttles", "FunctionName", local.lambda_name]
          ]
          view   = "timeSeries"
          region = var.aws_region
          title  = "Lambda Metrics"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          metrics = [
            ["AWS/ApiGateway", "5XXError", "ApiId", module.apigateway.rest_api_id, { "stat" : "Sum" }],
            ["AWS/ApiGateway", "Latency", "ApiId", module.apigateway.rest_api_id, { "stat" : "Average" }]
          ]
          view   = "timeSeries"
          region = var.aws_region
          title  = "API Gateway Metrics"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 24
        height = 6
        properties = {
          metrics = [
            ["AWS/DynamoDB", "ThrottledRequests", "TableName", module.dynamodb.table_name, { "stat" : "Sum" }],
            ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", module.dynamodb.table_name, { "stat" : "Sum" }],
            ["AWS/DynamoDB", "ConsumedWriteCapacityUnits", "TableName", module.dynamodb.table_name, { "stat" : "Sum" }]
          ]
          view   = "timeSeries"
          region = var.aws_region
          title  = "DynamoDB Metrics"
        }
      }
    ]
  })
}

output "cloudwatch_dashboard_name" {
  value       = aws_cloudwatch_dashboard.main.dashboard_name
  description = "Name of the CloudWatch dashboard"
}
