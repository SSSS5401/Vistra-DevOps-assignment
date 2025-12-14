resource "aws_kms_key" "vistra" {
  description             = "Customer master key for Vistra resources"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = local.common_tags
}

resource "aws_kms_alias" "vistra_alias" {
  name          = "alias/vistra-cmk"
  target_key_id = aws_kms_key.vistra.key_id
}
