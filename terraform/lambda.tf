data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function.py"
  output_path = "${path.module}/.terraform/lambda_function.zip"
}

resource "aws_lambda_function" "app" {
  function_name = "${var.project_name}-health-check"
  role          = aws_iam_role.lambda_role.arn

  filename         = data.archive_file.lambda_package.output_path
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  timeout          = 10

  environment {
    variables = {
      PROJECT_NAME = var.project_name
    }
  }

  tags = {
    Name = "${var.project_name}-health-check"
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.app.function_name}"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-lambda-logs"
  }
}

resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "${var.project_name}-health-check-schedule"
  description         = "Periodically invokes the application health-check Lambda"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = aws_cloudwatch_event_rule.lambda_schedule.name
  arn  = aws_lambda_function.app.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}
