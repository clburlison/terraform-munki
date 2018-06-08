# terraform-munki module

This terraform module creates all the necessary resources in AWS for highly
scalable munki web setup using AWS S3 for object storage and AWS CloudFront
(CDN) for content distribution. You can optionally secure the CDN via signed
URLs so only clients that have your signing certificate can download content.

## Table of Contents

* [**High Level Features**](#high-level-features)
* [**Versions**](#versions)
* [**Terraform Usage**](#terraform-usage)
* [**CloudFront signing key**](#cloudfrount-signing-key)
* [**SNS Alerts**](#sns-alerts)
* [**Lambda Notes**](#lambda-notes)
* [**Inputs**](#inputs)
* [**Outputs**](#outputs)

## High Level Features

* Restrictions on the S3 bucket to disallow any direct connections
* Use a custom DNS name for the web server or use a supplied URL from AWS
* Rebuild the catalog files whenever a pkginfo file or icon is updated or modified
* Only pay for what you use
* Optional SNS Alert when a warning or error happen during `makecatalog` run
* Short 2 minute TTL values on catalogs/* and /icons/*.plist allow clients to get updates quickly
* Long 24 hour TTL values on all other resources allow large packages to stay cached on the CDN

## Versions

At this time, it is impossible to supply your own lambda payload as such you
are stuck on the following versions.

* Munki - [v3.2.1]
* Munki s3Repo Plugin - [0.4.4](https://github.com/clburlison/Munki-s3Repo-Plugin)

## Terraform Usage

```hcl
module "munki-service" {
  source = "git@github.com:clburlison/terraform-munki.git"
  s3_bucket_name = "megacorp-munki-repo"

  tags {
    Environment  = "prod"
    BusinessUnit = "ClientABC"
  }
}
```

## CloudFront signing key

The CloudFront signing key can not be automatically created. This key can also
only be created by the root account owner, administrator IAM users will not
work.

The creation process can be followed in the following Amazon doc:

[To create CloudFront key pairs]

or via the following graphic:

![CF Key Creation](pics/cf_key_creation.png)

## SNS Alerts

Terraform is unable to create and validate Simple Notification Service (SNS)
resources so a topic and subscription must be created manually. The following
steps will guide you through an email alert:

1. Log into the AWS Console
1. Go to the Simple Notification Service (SNS) service
1. Create a new topic
1. Click on the created topic ARN to go to the details page
1. Create a subscription
1. Select the protocol and options you want
1. Confirm the subscription (required for the email protocol)
1. Copy the Topic ARN from this page and use in the terraform `alarm_arn` variable

## Lambda Notes

The `lambda_makecatalogs.py` file runs as a AWS Lambda function. It is
triggered from the following s3 events:

* a file under pkginfo/ is modified or uploaded
* a file under icons/ with the extensions of the `.png` or `.jpg` is modified or uploaded

If this setup is destroyed and recreated the 'munki-s3-rw' policy will need to be re-applied to the 'munki_s3' user.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alarm_arn | The arn to send alerts to on lambda errors and warnings | string | `` | no |
| cf_default_certificate | true if you want viewers to use HTTPS to request your objects and you're using the CloudFront domain name for your distribution. Specify this, cf_acm_certificate_arn, or cf_iam_certificate_id | string | `true` | no |
| cf_dns_aliases | Optionally a list of dns aliases to assign to the CloudFront distribution point | list | `<list>` | no |
| cf_minimum_protocol_version | The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections. One of SSLv3, TLSv1, TLSv1_2016, TLSv1.1_2016 or TLSv1.2_2018 | string | `TLSv1.2_2018` | no |
| cf_price_class | The CloudFront pricing tier. One of PriceClass_All, PriceClass_200, PriceClass_100 | string | `PriceClass_All` | no |
| cf_ssl_cert_arn | The ARN of the AWS Certificate Manager certificate to use. Specify this, cf_cloudfront_default_certificate, or cf_iam_certificate_id. The ACM certificate must be in US-EAST-1 | string | `` | no |
| cf_ssl_support_method | Specifies how you want CloudFront to serve HTTPS requests. Required if you specify acm_certificate_arn. One of vip or sni-only. vip is $600 a month don't select that option! | string | `` | no |
| cf_trusted_signers | The AWS accounts, if any, that you want to allow to create signed URLs for private content. Use ['self'] if you want to target the account that owns this CloudFront distribution point | list | `<list>` | no |
| name | Name to be used on all resources as the identifier | string | `munki` | no |
| s3_bucket_create | Set to true to create a new s3 bucket. If false you can reuse a current bucket | string | `true` | no |
| s3_bucket_name | The s3 bucket name to use | string | - | yes |
| tags | A map of tags to add to all resources | map | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| cf_domain_name | The cloudfront distribution point domain name |
| cf_hosted_zone_id | The cloudfront distribution point zone id |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- html urls -->

[To create CloudFront key pairs]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html#private-content-creating-cloudfront-key-pairs
[v3.2.1]: https://github.com/munki/munki/releases/tag/v3.2.1
[CHANGELOG.md]: ./CHANGELOG.md
