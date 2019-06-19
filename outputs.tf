output "cf_domain_name" {
  description = "The cloudfront distribution point domain name"
  value       = aws_cloudfront_distribution.munki_s3_distribution.domain_name
}

output "cf_hosted_zone_id" {
  description = "The cloudfront distribution point zone id"
  value       = aws_cloudfront_distribution.munki_s3_distribution.hosted_zone_id
}

