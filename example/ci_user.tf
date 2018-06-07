resource "aws_iam_user" "ci_user" {
  name = "${var.ci_user_name}"
}

resource "aws_iam_access_key" "ci_key" {
  user = "${aws_iam_user.ci_user.name}"
}

resource "aws_iam_user_policy" "ci_munki_s3_rw" {
  name = "${aws_iam_user.ci_user.name}"
  user = "${aws_iam_user.ci_user.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3_bucket_name}-${random_id.code.hex}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3_bucket_name}-${random_id.code.hex}/*"
            ]
        }
    ]
}
EOF
}
