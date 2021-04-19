variable "acm_certificate_arn" {
  description = "The Certificate Manager ARN to associate with the CloudFront distribution"
  default     = "arn:aws:acm:us-east-1:029516313545:certificate/580dceb0-1201-4b6c-b4de-3c50ca3f272c"
}

variable "ci_user_name" {
  description = "The limited IAM username for automation purposes"
  default     = "ci_munki_s3_rw"
}

variable "region" {
  description = "The AWS region to create resources in"
  default     = "us-east-1"
}

variable "route53_record_name" {
  description = "The Route 53 A record name"
  default     = "munki-demo.clb.ai"
}

variable "route53_zone" {
  description = "The Route 53 zone name"
  default     = "clb.ai"
}

variable "s3_bucket_name" {
  description = "The s3 bucket name"
  default     = "clb-munki-repo-demo"
}

variable "server_side_makecatalogs" {
  description = "Set to true to enable server side makecatalogs when s3 bucket changes happen"
  default     = false
}
