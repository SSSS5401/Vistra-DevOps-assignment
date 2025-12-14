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
      "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.app_name}-*",
      "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.app_name}-*:*"
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
      module.dynamodb.table_arn
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

data "aws_iam_policy_document" "eventbridge_put_events" {
  statement {
    effect = "Allow"
    actions = [
      "events:PutEvents"
    ]
    resources = [
      "arn:aws:events:*:${data.aws_caller_identity.current.account_id}:event-bus/*"
    ]
  }
}

resource "aws_iam_policy" "eventbridge_put_policy" {
  name   = "${var.app_name}-lambda-put-events"
  policy = data.aws_iam_policy_document.eventbridge_put_events.json
  tags   = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_put_events_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.eventbridge_put_policy.arn
}