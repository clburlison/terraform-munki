variable "alarm_arn" {
  description = "The arn to send alerts to on lambda errors and warnings"
  default     = ""
}

variable "name" {
  description = "Name to be used on all resources as the identifier"
  default     = "munki"
}

variable "s3_bucket_name" {
  description = "The s3 bucket name to use"
}

variable "s3_bucket_create" {
  description = "Set to true to create a new s3 bucket. If false you can reuse a current bucket"
  default     = true
}

variable "cf_default_certificate" {
  description = "true if you want viewers to use HTTPS to request your objects and you're using the CloudFront domain name for your distribution. Specify this, cf_acm_certificate_arn, or cf_iam_certificate_id"
  default     = "true"
}

variable "cf_dns_aliases" {
  type        = "list"
  description = "Optionally a list of dns aliases to assign to the CloudFront distribution point"
  default     = []
}

variable "cf_trusted_signers" {
  type        = "list"
  description = "The AWS accounts, if any, that you want to allow to create signed URLs for private content. Use ['self'] if you want to target the account that owns this CloudFront distribution point"
  default     = []
}

variable "cf_ssl_cert_arn" {
  description = "The ARN of the AWS Certificate Manager certificate to use. Specify this, cf_cloudfront_default_certificate, or cf_iam_certificate_id. The ACM certificate must be in US-EAST-1"
  default     = ""
}

variable "cf_minimum_protocol_version" {
  description = "The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections. One of SSLv3, TLSv1, TLSv1_2016, TLSv1.1_2016 or TLSv1.2_2018"
  default     = "TLSv1.2_2018"
}

variable "cf_price_class" {
  description = "The CloudFront pricing tier. One of PriceClass_All, PriceClass_200, PriceClass_100"
  default     = "PriceClass_All"
}

variable "cf_ssl_support_method" {
  description = "Specifies how you want CloudFront to serve HTTPS requests. Required if you specify acm_certificate_arn. One of vip or sni-only. vip is $600 a month don't select that option!"
  default     = ""
}

variable "tags" {
  type        = "map"
  description = "A map of tags to add to all resources"
  default     = {}
}
