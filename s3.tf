# S3 bucket for Lambda deployment packages with versioning enabled
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.app_name}-lambda"
  tags   = local.common_tags
}

resource "aws_s3_bucket_versioning" "bucket_version" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}