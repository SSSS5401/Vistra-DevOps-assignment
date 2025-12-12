#########################################################################
# IAM roles for Lambda execution following least-privilege principles

data "aws_iam_policy_document" "assume_lambda_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.app_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda_role.json

  tags = local.common_tags
}

data "aws_iam_policy_document" "cloudwatch_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

data "aws_iam_policy_document" "dynamodb_policy" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
    ]
    resources = [
      "arn:aws:dynamodb:*:*:table/ApplicationData"
    ]
  }
}

resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "${var.app_name}-lambda-cloudwatch-policy"
  description = ""
  policy      = data.aws_iam_policy_document.cloudwatch_policy.json

  tags = local.common_tags
}

resource "aws_iam_policy" "dynamodb_policy" {
  name        = "${var.app_name}-lambda-dynamodb-policy"
  description = ""
  policy      = data.aws_iam_policy_document.dynamodb_policy.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}