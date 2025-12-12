resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.app_name}-log-group"
  retention_in_days = 7
  tags              = local.common_tags
}