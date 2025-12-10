output "whoami" {
  value       = data.aws_caller_identity.current.arn
  description = "The ARN of the current AWS identity"
}

# output "api_endpoint" {
#   value       = module.api_gateway.api_endpoint
#   description = "The invoke URL of the API Gateway"
# }

# output "lambda_function_arn" {
#   value       = module.lambda.lambda_arn
#   description = "ARN of the Lambda function"
# }

# output "dynamodb_table_arn" {
#   value       = module.dynamodb.table_arn
#   description = "ARN of the DynamoDB table"
# }

# output "s3_bucket_name" {
#   value       = module.s3.bucket_name
#   description = "Name of the S3 bucket for Lambda packages"
# }