resource "aws_iam_policy" "munki-s3-rw" {
  name        = "${var.name}-s3-rw"
  path        = "/"
  description = "Munki s3 policy for read/write access to the s3 munki repo bucket. Used for automation purposes."
  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action":[
        "s3:ListBucket"
      ],
      "Resource":[
        "arn:aws:s3:::${var.s3_bucket_name}"
      ]
    },
    {
      "Effect":"Allow",
      "Action":[
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource":[
        "arn:aws:s3:::${var.s3_bucket_name}/*"
      ]
    }
  ]
}
EOF

}
