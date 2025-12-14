module "lambda" {
  source               = "./modules/lambda"
  function_name        = "LambdaHandler"
  s3_bucket            = aws_s3_bucket.bucket.id
  source_path          = "${path.root}/functions/items-api"
  execute_role         = aws_iam_role.lambda_role.arn
  cloudwatch_log_group = aws_cloudwatch_log_group.this.name
  tags                 = local.common_tags
}
