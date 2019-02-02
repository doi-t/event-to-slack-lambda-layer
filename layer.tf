locals {
  layer_name           = "event-to-slack-lambda-layer"
  layer_python_version = "3.7"
}

module "layer_package" {
  source           = "github.com/doi-t/terraform-lambda-python-package?ref=v0.2.0"
  package_name     = "${local.layer_name}"
  python_version   = "${local.layer_python_version}"
  is_lambda_layers = true
  source_dir       = "src/layers/sample"
}

# > For larger deployment packages it is recommended by Amazon to upload via S3, since the S3 API has better support for uploading large files efficiently.
# Ref. https://www.terraform.io/docs/providers/aws/r/lambda_layer_version.html
resource "aws_lambda_layer_version" "event_to_slack_lambda_layer" {
  filename         = "${module.layer_package.package_file_path}"
  source_code_hash = "${module.layer_package.zip_package_sha256}"
  layer_name       = "${local.layer_name}"

  compatible_runtimes = ["python${local.layer_python_version}"]
}
