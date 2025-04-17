# Author Dolapo Ajayi

resource "aws_lambda_function" "stop_infra" {
  function_name = "stop-infra"
  handler       = "stop.lambda_handler"
  runtime       = "python3.12"
  filename      = "${path.module}/lambda/stop.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/stop.zip")
  role          = aws_iam_role.lambda_ec2_control.arn
}

resource "aws_lambda_function" "start_infra" {
  function_name = "start-infra"
  handler       = "start.lambda_handler"
  runtime       = "python3.12"
  filename      = "${path.module}/lambda/start.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/start.zip")
  role          = aws_iam_role.lambda_ec2_control.arn
}