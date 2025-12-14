variable "apigateway_name" {
  type        = string
  description = "The name of the REST API Gateway"
  validation {
    condition     = length(var.apigateway_name) > 3
    error_message = "REST API Gateway name must be longer than 3 characters."
  }
}

variable "apigateway_setting" {
  type = object({
    paths = list(object({
      path                 = string
      methods              = list(string)
      lambda_function_name = string
  })) })
  description = "A map of settings for the API Gateway"
  default = {
    paths = [
      {
        path                 = "items"
        methods              = ["GET", "POST", "PUT", "DELETE"]
        lambda_function_name = ""
      }
    ]
  }
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}

variable "enable_access_logging" {
  type        = bool
  description = "Enable API Gateway access logging to CloudWatch Logs"
  default     = true
}

variable "access_log_retention_in_days" {
  type        = number
  description = "Retention days for API Gateway access logs"
  default     = 90
}

variable "access_log_group_kms_key_arn" {
  type        = string
  description = "Optional KMS Key ARN to encrypt API Gateway access logs"
  default     = ""
}