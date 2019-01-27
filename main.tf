data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  function_name       = "event-to-slack"
  python_version      = "3.7"
  lambda_package_file = "package/${local.function_name}.zip"
  source_dir          = "${path.module}/package"
}

# generate source code hash depending on lambda_package_file and source code in 'src' directory
# Note that any code changes in src directory changes the result of source code hash
# Ref. https://github.com/hashicorp/terraform/issues/10878#issuecomment-453241734
data "external" "source_code_hash" {
  program = ["bash", "deployments/check-source-code-hash.sh"]

  query = {
    package_file = "${local.lambda_package_file}"
  }
}

# Ref. https://github.com/hashicorp/terraform/issues/8344#issuecomment-345807204
resource "null_resource" "create_lambda_package" {
  triggers {
    src_hash = "${data.external.source_code_hash.result["sha256"]}"
  }

  provisioner "local-exec" {
    command = "./deployments/create-lambda-package.sh ${local.function_name} ${local.python_version}"
  }
}

# NOTE: 'terrraform plan' does not evaluate 'data'.
# As a result, you always see a change of source_code_hash in plan but it won't happen in apply 
# if there is no code change in 'src' directory.
# Ref. https://github.com/hashicorp/terraform/issues/17034
data "archive_file" "lambda_zip_package" {
  type        = "zip"
  source_dir  = "${local.source_dir}"
  output_path = "${path.module}/${local.lambda_package_file}"

  depends_on = ["null_resource.create_lambda_package"]
}

resource "aws_lambda_function" "event_to_slack" {
  filename         = "${local.lambda_package_file}"
  source_code_hash = "${data.archive_file.lambda_zip_package.output_base64sha256}"
  function_name    = "${local.function_name}"
  role             = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/lambda_basic_execution"
  handler          = "main.handler"
  runtime          = "python${local.python_version}"
  timeout          = 300
}
