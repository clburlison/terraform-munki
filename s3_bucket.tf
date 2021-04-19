data "aws_iam_policy_document" "munki_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.s3_bucket_name}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cf-identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket" "munki-bucket" {
  count  = var.s3_bucket_create != "false" ? 1 : 0
  bucket = var.s3_bucket_name
  acl    = "private"
  policy = data.aws_iam_policy_document.munki_s3_policy.json

  lifecycle {
    # This can't be interpolationed as a variable. https://github.com/hashicorp/terraform/issues/3116
    # This bucket must be manually destroyed in the AWS console or via API for safety purposes.
    prevent_destroy = false
  }

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = var.server_side_makecatalogs ? 1 : 0
  bucket = var.s3_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda[0].arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_prefix       = "icons/"
    filter_suffix       = ".png"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda[0].arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_prefix       = "icons/"
    filter_suffix       = ".jpg"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda[0].arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    filter_prefix       = "pkgsinfo/"
  }
}
