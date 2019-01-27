data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  function_name           = "event-to-slack-lambda-function"
  function_python_version = "3.7"
}

module "function_package" {
  source         = "modules/create_lambda_package"
  package_name   = "${local.function_name}"
  python_version = "${local.function_python_version}"
  source_dir     = "src/event-to-slack"
}

resource "aws_lambda_function" "event_to_slack" {
  filename         = "${module.function_package.package_file_path}"
  source_code_hash = "${module.function_package.zip_package_sha256}"
  function_name    = "${local.function_name}"
  layers           = ["${aws_lambda_layer_version.event_to_slack_lambda_layer.layer_arn}"]
  role             = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/lambda_basic_execution"
  handler          = "main.handler"
  runtime          = "python${local.function_python_version}"
  timeout          = 300
}
