data "aws_caller_identity" "current" {
}

# Used for basic basic auth
data "archive_file" "basic_auth_payload" {
  type = "zip"
  source {
    content = templatefile("${path.module}/basic_auth.js.tpl", {
      auth_user     = var.basic_auth_user,
      auth_password = var.basic_auth_password
    })
    filename = "index.js"
  }
  output_path = "basic_auth_payload.zip"
}

data "aws_iam_policy_document" "lambda_execution_role_assume_role_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "edgelambda.amazonaws.com",
        "lambda.amazonaws.com",
      ]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_execution_role_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["logs:*"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  count = var.basic_auth_user != "" ? 1 : 0
  name  = "${var.name}_basic_auth_lambda"

  assume_role_policy = data.aws_iam_policy_document.lambda_execution_role_assume_role_policy_document.json
  path               = "/service/"
  description        = "Basic Auth @Edge Lambda Execution Role for munki resources"
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

resource "aws_iam_role_policy" "lambda_execution_role_policy" {
  count  = var.basic_auth_user != "" ? 1 : 0
  name   = "${var.name}_private_resources_policy"
  role   = aws_iam_role.lambda_execution_role[0].id
  policy = data.aws_iam_policy_document.lambda_execution_role_policy_document.json
}

resource "aws_lambda_function" "basic_auth_lambda" {
  count            = var.basic_auth_user != "" ? 1 : 0
  filename         = data.archive_file.basic_auth_payload.output_path
  source_code_hash = data.archive_file.basic_auth_payload.output_base64sha256
  function_name    = "${var.name}_basic_auth"
  role             = aws_iam_role.lambda_execution_role[0].arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  timeout          = "2"
  description      = "Protect munki resources via basic auth."
  publish          = true

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

# Used for makecatalogs
resource "aws_lambda_permission" "allow_cloudwatch" {
  count          = var.server_side_makecatalogs ? 1 : 0
  statement_id   = "AllowExecutionFromCloudWatch"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.lambda[0].function_name
  principal      = "events.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
  source_arn     = "arn:aws:s3:::${var.s3_bucket_name}"
  qualifier      = aws_lambda_alias.alias[0].name
}

resource "aws_lambda_permission" "allow_bucket" {
  count          = var.server_side_makecatalogs ? 1 : 0
  statement_id   = "AllowExecutionFromS3Bucket"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.lambda[0].function_name
  principal      = "s3.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
  source_arn     = "arn:aws:s3:::${var.s3_bucket_name}"
}

resource "aws_lambda_alias" "alias" {
  count            = var.server_side_makecatalogs ? 1 : 0
  name             = "makecatalogs"
  description      = "makecatalogs lambda function"
  function_name    = aws_lambda_function.lambda[0].function_name
  function_version = "$LATEST"
}

resource "aws_lambda_function" "lambda" {
  count = var.server_side_makecatalogs ? 1 : 0
  # TODO: We should be able to pass custom lambda payload path and sha256 from the code calling this module. -clayton
  filename         = "${path.module}/lambda_payload.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_payload.zip")
  function_name    = "munki_makecatalogs"
  role             = aws_iam_role.makecatalogs_lambda[0].arn
  handler          = "lambda_makecatalogs.event_handler"
  runtime          = "python3.9"
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
  count      = var.server_side_makecatalogs ? 1 : 0
  role       = aws_iam_role.makecatalogs_lambda[0].id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_munki_s3_rw_policy" {
  count      = var.server_side_makecatalogs ? 1 : 0
  role       = aws_iam_role.makecatalogs_lambda[0].id
  policy_arn = aws_iam_policy.munki-s3-rw.arn
}

resource "aws_iam_role" "makecatalogs_lambda" {
  count       = var.server_side_makecatalogs ? 1 : 0
  name        = "makecatalogs_lambda"
  description = "Munki makecatalogs"
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )

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

