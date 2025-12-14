resource "aws_sqs_queue" "event_dlq" {
  name = "${var.app_name}-events-dlq"
  tags = local.common_tags
}

# EventBridge rule for custom app events
resource "aws_cloudwatch_event_rule" "app_events" {
  name = "${var.app_name}-app-events"
  event_pattern = jsonencode({
    source        = ["my.app"],
    "detail-type" = ["app.event"]
  })
}

# Target the event processor lambda with DLQ
resource "aws_cloudwatch_event_target" "app_events_target" {
  rule = aws_cloudwatch_event_rule.app_events.name
  arn  = module.lambda_event_processor.lambda_function_arn

  dead_letter_config {
    arn = aws_sqs_queue.event_dlq.arn
  }
}

# Scheduled rule to run the scheduled worker
resource "aws_cloudwatch_event_rule" "scheduled_worker" {
  name                = "${var.app_name}-scheduled-worker"
  schedule_expression = var.scheduled_worker_expression
}

resource "aws_cloudwatch_event_target" "scheduled_worker_target" {
  rule = aws_cloudwatch_event_rule.scheduled_worker.name
  arn  = module.lambda_scheduled_worker.lambda_function_arn

  dead_letter_config {
    arn = aws_sqs_queue.event_dlq.arn
  }
}

# Allow EventBridge to invoke lambdas
resource "aws_lambda_permission" "allow_eventbridge_invoke_processor" {
  statement_id  = "AllowEventBridgeInvokeProcessor"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_event_processor.lambda_function_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.app_events.arn
}

resource "aws_lambda_permission" "allow_eventbridge_invoke_scheduled" {
  statement_id  = "AllowEventBridgeInvokeScheduled"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_scheduled_worker.lambda_function_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduled_worker.arn
}

# Alarm: DLQ has messages
resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "${var.app_name}-dlq-messages"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  dimensions = {
    QueueName = aws_sqs_queue.event_dlq.name
  }
}

output "event_dlq_name" {
  value       = aws_sqs_queue.event_dlq.name
  description = "Name of the Event DLQ"
}
