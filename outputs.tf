output "cf_domain_name" {
  description = "The cloudfront distribution point domain name"
  value       = join("", aws_cloudfront_distribution.munki[*].domain_name, aws_cloudfront_distribution.munki_basic_auth[*].domain_name)
}

output "cf_hosted_zone_id" {
  description = "The cloudfront distribution point zone id"
  value       = join("", aws_cloudfront_distribution.munki[*].hosted_zone_id, aws_cloudfront_distribution.munki_basic_auth[*].hosted_zone_id)
}
