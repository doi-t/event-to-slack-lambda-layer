output "lambda_function_name" {
  value = "${aws_lambda_function.event_to_slack.function_name}"
}

output "lambda_source_code_hash" {
  value = "${aws_lambda_function.event_to_slack.source_code_hash}"
}

output "lambda_last_modified" {
  value = "${aws_lambda_function.event_to_slack.last_modified}"
}

output "layer_arn" {
  value = "${aws_lambda_layer_version.event_to_slack_lambda_layer.layer_arn}"
}

output "layer_source_code_hash" {
  value = "${aws_lambda_layer_version.event_to_slack_lambda_layer.source_code_hash}"
}
