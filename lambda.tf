data "aws_caller_identity" "current" {
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id   = "AllowExecutionFromCloudWatch"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.lambda.function_name
  principal      = "events.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
  source_arn     = "arn:aws:s3:::${var.s3_bucket_name}"
  qualifier      = aws_lambda_alias.alias.name
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id   = "AllowExecutionFromS3Bucket"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.lambda.function_name
  principal      = "s3.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
  source_arn     = "arn:aws:s3:::${var.s3_bucket_name}"
}

resource "aws_lambda_alias" "alias" {
  name             = "makecatalogs"
  description      = "makecatalogs lambda function"
  function_name    = aws_lambda_function.lambda.function_name
  function_version = "$LATEST"
}

resource "aws_lambda_function" "lambda" {
  # TODO: We should be able to pass custom lambda payload path and sha256 from the code calling this module. -clayton
  filename         = "${path.module}/lambda_payload.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_payload.zip")
  function_name    = "munki_makecatalogs"
  role             = aws_iam_role.makecatalogs_lambda.arn
  handler          = "lambda_makecatalogs.event_handler"
  runtime          = "python2.7"
  timeout          = "180"
  description      = "Run makecatalogs on the munki repo bucket when a pkginfo or icon item is modified."

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

resource "aws_iam_role_policy_attachment" "lambda_iam_policy_basic_execution" {
  role       = aws_iam_role.makecatalogs_lambda.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_munki_s3_rw_policy" {
  role       = aws_iam_role.makecatalogs_lambda.id
  policy_arn = aws_iam_policy.munki-s3-rw.arn
}

resource "aws_iam_role" "makecatalogs_lambda" {
  name        = "makecatalogs_lambda"
  description = "Munki makecatalogs"

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

