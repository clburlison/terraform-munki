provider "aws" {
  region = "${var.region}"
}

module "munki-service" {
  source = "../"

  s3_bucket_name   = "${var.s3_bucket_name}-${random_id.code.hex}"
  s3_bucket_create = true

  cf_default_certificate = false
  cf_dns_aliases         = ["${var.route53_record_name}"]

  cf_ssl_support_method = "sni-only"
  cf_ssl_cert_arn       = "${var.acm_certificate_arn}"

  tags {
    Environment = "${terraform.workspace}"
  }
}

resource "random_id" "code" {
  byte_length = 4
}

data "aws_route53_zone" "main" {
  name = "${var.route53_zone}."
}

resource "aws_route53_record" "dns" {
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "${var.route53_record_name}."
  type    = "A"

  alias {
    name                   = "${module.munki-service.cf_domain_name}"
    zone_id                = "${module.munki-service.cf_hosted_zone_id}"
    evaluate_target_health = false
  }
}
