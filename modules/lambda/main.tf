#########################################################################
# Lambda function for items API
data "archive_file" "this" {
  type = "zip"
  #   source_dir  = "${path.root}/functions/items-api"
  source_dir  = var.source_path
  output_path = "${path.module}/handler.zip"
}

resource "aws_s3_object" "this" {
  #   bucket = aws_s3_bucket.bucket.id
  bucket = var.s3_bucket
  key    = "handler.zip"
  source = data.archive_file.this.output_path

  etag = filemd5(data.archive_file.this.output_path)

  tags = var.tags

  depends_on = [
    data.archive_file.this,
  ]
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  handler       = "index.handler" # Assuming Node.js with index.js and handler function
  runtime       = "nodejs22.x"
  #   role             = aws_iam_role.lambda_role.arn
  role             = var.execute_role
  source_code_hash = filebase64sha256(data.archive_file.this.output_path) # Triggers update on code change

  s3_bucket = var.s3_bucket
  s3_key    = aws_s3_object.this.key

  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
    log_group = var.cloudwatch_log_group
  }

  tags = var.tags

  depends_on = [
    aws_s3_object.this,
  ]
}