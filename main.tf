data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  resource_prefix         = "event-to-slack"
  function_name           = "${local.resource_prefix}-lambda-function"
  function_python_version = "3.7"
}

module "function_package" {
  source         = "github.com/doi-t/terraform-lambda-python-package?ref=v0.2.0"
  package_name   = "${local.function_name}"
  python_version = "${local.function_python_version}"
  source_dir     = "src/event_to_slack"
}

resource "aws_lambda_function" "event_to_slack" {
  filename         = "${module.function_package.package_file_path}"
  source_code_hash = "${module.function_package.zip_package_sha256}"
  function_name    = "${local.function_name}"
  layers           = ["${aws_lambda_layer_version.event_to_slack_lambda_layer.layer_arn}"]
  role             = "${aws_iam_role.event_to_slack.arn}"
  handler          = "main.handler"
  runtime          = "python${local.function_python_version}"
  timeout          = 300
}

resource "aws_iam_role" "event_to_slack" {
  name               = "${local.resource_prefix}"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_assume_role.json}"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "event_to_slack" {
  name   = "${local.resource_prefix}"
  role   = "${aws_iam_role.event_to_slack.id}"
  policy = "${data.aws_iam_policy_document.event_to_slack.json}"
}

data "aws_iam_policy_document" "event_to_slack" {
  statement {
    sid    = "AWSCloudWatchLogsPermissons"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    sid = "AWSSSMParameterPermissions"

    effect = "Allow"

    actions = ["ssm:GetParameter"]

    resources = ["${aws_ssm_parameter.slack_bot_token.arn}"]
  }
}
