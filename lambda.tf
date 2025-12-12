module "lambda" {
  source        = "./modules/lambda"
  function_name = "LambdaHandler"
  s3_bucket     = aws_s3_bucket.bucket.id
  source_path   = "${path.root}/functions/items-api"
  execute_role  = aws_iam_role.lambda_role.arn
  cloudwatch_log_group = aws_cloudwatch_log_group.this.name
  tags = local.common_tags
}

module "apigateway" {
  source          = "./modules/api-gateway"
  apigateway_name = "ItemsAPI"
  apigateway_setting = {
    paths = [
      {
        path    = "items"
        methods = ["GET", "POST", "PUT", "DELETE"]
        # lambda_function_arn = module.lambda.lambda_function_invoke_arn
        lambda_function_name = "LambdaHandler"
      }
    ]
  }
  tags = local.common_tags

  depends_on = [
    module.lambda
  ]
}