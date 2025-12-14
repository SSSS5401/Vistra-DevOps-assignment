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

# Access log bucket for S3 access logs
resource "aws_s3_bucket" "access_logs" {
  bucket = "${var.app_name}-logs"
  # `acl` is deprecated; use the aws_s3_bucket_acl resource to set the
  # `log-delivery-write` permission required for S3 access logging.

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.vistra.arn
      }
    }
  }

  tags = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "bucket_pub_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "access_logs_pub_block" {
  bucket = aws_s3_bucket.access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "bucket_logging" {
  bucket        = aws_s3_bucket.bucket.id
  target_bucket = aws_s3_bucket.access_logs.bucket
  target_prefix = "${var.app_name}/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_sse" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.vistra.arn
    }
  }
}

resource "aws_s3_bucket_acl" "access_logs_acl" {
  bucket = aws_s3_bucket.access_logs.id
  acl    = "log-delivery-write"
}