#########################################################################
# DynamoDB module
module "dynamodb" {
  source     = "./modules/dynamodb"
  table_name = var.dynamodb_table_name
  tags       = local.common_tags
}