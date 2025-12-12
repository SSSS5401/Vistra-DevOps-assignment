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

