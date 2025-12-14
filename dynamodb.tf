#########################################################################
# DynamoDB module
module "dynamodb" {
  source      = "./modules/dynamodb"
  table_name  = var.dynamodb_table_name
  tags        = local.common_tags
  kms_key_arn = aws_kms_key.vistra.arn
}