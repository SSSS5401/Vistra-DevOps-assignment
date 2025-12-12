#########################################################################
# DynamoDB table for application data with encryption enabled
resource "aws_dynamodb_table" "dynamodb-table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = local.common_tags
}