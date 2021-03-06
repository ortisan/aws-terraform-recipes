# Bitcoin now
resource "aws_iam_role" "bitcoin_now_lambda" {
  name = "bitcoin_now_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_policy" "bitcoin_now_lambda" {
  name        = "bitcoin_now_lambda"
  path        = "/"
  description = "Policies for lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:*",
        "dynamodb:*",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "bitcoin_now_lambda" {
  policy_arn = aws_iam_policy.bitcoin_now_lambda.arn
  role       = aws_iam_role.bitcoin_now_lambda.name
}

resource "aws_cloudwatch_log_group" "bitcoin_now_lambda" {
  name              = "/aws/lambda/${aws_lambda_function.bitcoin_now_lambda.function_name}"
  retention_in_days = 1
}

resource "aws_lambda_function" "bitcoin_now_lambda" {
  function_name = "bitcoin_now_lambda"
  filename      = "lambda-sources/deployment.zip"
  role          = aws_iam_role.bitcoin_now_lambda.arn
  handler       = "bitcoinnow.handle"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("lambda-sources/deployment.zip")

  runtime = "python3.8"
}