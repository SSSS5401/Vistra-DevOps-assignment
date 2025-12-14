output "api_gateway_arn" {
  value       = aws_api_gateway_rest_api.this.arn
  description = "The ARN of the REST API Gateway"
}

output "api_gateway_endpoint" {
  value       = aws_api_gateway_stage.prod.invoke_url
  description = "The ARN of the REST API Gateway"
}

output "rest_api_id" {
  value       = aws_api_gateway_rest_api.this.id
  description = "The rest API id"
}

output "api_name" {
  value       = aws_api_gateway_rest_api.this.name
  description = "The API Gateway name"
}