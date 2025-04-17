# Author Dolapo Ajayi

# CloudWatch rules to stop and start infrastructure based on UK working hours (BST/GMT)

# This resource shuts down the infrastructure at 6 PM BST (5 PM UTC) on weekdays including Saturdays
resource "aws_cloudwatch_event_rule" "shutdown_evening" {
  name                = "shutdown-infra-outside-working-hours"
  description         = "Stop infrastructure at 6 PM BST (5 PM UTC) on weekdays including Saturdays"
  schedule_expression = "cron(0 17 ? * MON-SAT *)"
}

# This resource starts up the infrastructure at 8 AM BST (7 AM UTC) on weekdays including Saturdays
resource "aws_cloudwatch_event_rule" "startup_morning" {
  name                = "startup-infra-during-working-hours"
  description         = "Start infrastructure at 8 AM BST (7 AM UTC) on weekdays including Saturdays"
schedule_expression = "cron(0 7 ? * MON-SAT *)"
}

resource "aws_cloudwatch_event_target" "shutdown_lambda_target" {
  rule      = aws_cloudwatch_event_rule.shutdown_evening.name
  target_id = "ShutdownInfra"
  arn       = aws_lambda_function.stop_infra.arn
}

resource "aws_cloudwatch_event_target" "startup_lambda_target" {
  rule      = aws_cloudwatch_event_rule.startup_morning.name
  target_id = "StartupInfra"
  arn       = aws_lambda_function.start_infra.arn
}

resource "aws_lambda_permission" "allow_shutdown" {
  statement_id  = "AllowExecutionFromCloudWatchShutdown"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stop_infra.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.shutdown_evening.arn
}

resource "aws_lambda_permission" "allow_startup" {
  statement_id  = "AllowExecutionFromCloudWatchStartup"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.start_infra.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.startup_morning.arn
}