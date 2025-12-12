variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy resources"
  validation {
    condition     = contains(["us-east-1", "us-west-2"], var.aws_region)
    error_message = "Region must be us-east-1 or us-west-2."
  }
}

variable "app_name" {
  type        = string
  default     = "items-api"
  description = "Name of the application"
  validation {
    condition     = length(var.app_name) > 3
    error_message = "App name must be longer than 3 characters."
  }
}

variable "dynamodb_table_name" {
  type        = string
  default     = "items"
  description = "Name of the DynamoDB table"
}

