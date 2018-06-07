output "access_key_id" {
  description = "The munki user access key"
  value       = "${aws_iam_access_key.ci_key.id}"
}

output "access_key_secret" {
  description = "The munki user secret key"
  value       = "${aws_iam_access_key.ci_key.secret}"
}

output "cf_domain_name" {
  description = "The CloudFront domain name"
  value       = "${module.munki-service.cf_domain_name}"
}

output "dns_name" {
  description = "DNS name from Route53 A record"
  value       = "${aws_route53_record.dns.name}"
}
