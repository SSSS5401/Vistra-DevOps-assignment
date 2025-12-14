module "lambda" {
  source               = "./modules/lambda"
  function_name        = "LambdaHandler"
  s3_bucket            = aws_s3_bucket.bucket.id
  source_path          = "${path.root}/functions/items-api"
  execute_role         = aws_iam_role.lambda_role.arn
  cloudwatch_log_group = aws_cloudwatch_log_group.this.name
  tags                 = local.common_tags
}

# Event-driven lambdas
module "lambda_event_processor" {
  source               = "./modules/lambda"
  function_name        = "EventProcessor"
  s3_bucket            = aws_s3_bucket.bucket.id
  source_path          = "${path.root}/functions/event-processor"
  execute_role         = aws_iam_role.lambda_role.arn
  cloudwatch_log_group = aws_cloudwatch_log_group.this.name
  tags                 = local.common_tags
  environment = {
    DYNAMODB_TABLE = var.dynamodb_table_name
  }
}

module "lambda_scheduled_worker" {
  source               = "./modules/lambda"
  function_name        = "ScheduledWorker"
  s3_bucket            = aws_s3_bucket.bucket.id
  source_path          = "${path.root}/functions/scheduled-worker"
  execute_role         = aws_iam_role.lambda_role.arn
  cloudwatch_log_group = aws_cloudwatch_log_group.this.name
  tags                 = local.common_tags
  environment = {
    DYNAMODB_TABLE = var.dynamodb_table_name
  }
}
