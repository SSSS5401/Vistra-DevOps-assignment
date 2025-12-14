variable "table_name" {
  type        = string
  description = "Name of the DynamoDB table"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the table"
  default     = {}
}
