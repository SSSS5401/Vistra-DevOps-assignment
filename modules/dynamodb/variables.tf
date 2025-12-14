variable "table_name" {
  type        = string
  description = "Name of the DynamoDB table"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the table"
  default     = {}
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of KMS key to use for server-side encryption (customer-managed)"
  default     = ""
}
