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

# Monitoring thresholds
variable "lambda_error_threshold" {
  type        = number
  default     = 5
  description = "Alarm threshold for Lambda errors (sum per minute)"
}

variable "lambda_duration_threshold_ms" {
  type        = number
  default     = 3000
  description = "Alarm threshold for Lambda duration (ms)"
}

variable "lambda_throttle_threshold" {
  type        = number
  default     = 1
  description = "Alarm threshold for Lambda throttles (sum per minute)"
}

variable "api_5xx_threshold" {
  type        = number
  default     = 5
  description = "Alarm threshold for API Gateway 5XX errors (sum per minute)"
}

variable "api_latency_threshold_ms" {
  type        = number
  default     = 1000
  description = "Alarm threshold for API Gateway latency (ms)"
}

variable "dynamodb_throttle_threshold" {
  type        = number
  default     = 1
  description = "Alarm threshold for DynamoDB throttled requests (sum per minute)"
}

variable "scheduled_worker_expression" {
  type        = string
  default     = "rate(5 minutes)"
  description = "Schedule expression for the scheduled worker lambda"
}

