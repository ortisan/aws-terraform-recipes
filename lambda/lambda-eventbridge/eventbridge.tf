
resource "aws_cloudwatch_event_rule" "every_minute" {
  name                = "every_minute"
  description         = "Fires every minute"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "bitcoinnow_by_minute" {
  rule = aws_cloudwatch_event_rule.every_minute.id
  arn  = aws_lambda_function.bitcoinnow_lambda.arn
}

resource "aws_lambda_permission" "allow_bitcoin_now_lambda_execution_permission" {
  statement_id  = "AllowBitcoinNowLambdaExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bitcoin_now_lambda.id
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_minute.arn
}