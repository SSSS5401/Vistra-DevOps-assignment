variable "function_name" {
  type        = string
  default     = "LambdaHandler"
  description = "The name of the lambda function"
  validation {
    condition     = length(var.function_name) > 3
    error_message = "Lambda function name must be longer than 3 characters."
  }
}

variable "source_path" {
  type        = string
  description = "The directory of lambda function code"
}

variable "execute_role" {
  type        = string
  nullable    = false
  description = "The arn of iam role for lambda execute"
}

variable "s3_bucket" {
  type        = string
  nullable    = false
  description = "The s3 bucket for lambda deployment package"
}

variable "cloudwatch_log_group" {
  type        = string
  nullable    = false
  description = "The cloudwatch log group for lambda function"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}

variable "environment" {
  type        = map(string)
  description = "Environment variables to set on the Lambda function"
  default     = {}
}