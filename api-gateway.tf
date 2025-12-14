module "apigateway" {
  source          = "./modules/api-gateway"
  apigateway_name = "ItemsAPI"
  apigateway_setting = {
    paths = [
      {
        path                 = "items"
        methods              = ["GET", "POST", "PUT", "DELETE"]
        lambda_function_name = "LambdaHandler"
      }
    ]
  }
  tags = local.common_tags

  depends_on = [
    module.lambda
  ]
}