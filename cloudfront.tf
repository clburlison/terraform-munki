resource "aws_cloudfront_origin_access_identity" "cf-identity" {
  comment = "Munki identity"
}

resource "aws_cloudfront_distribution" "munki_s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.munki-bucket.bucket_domain_name}"
    origin_id   = "myS3Origin"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.cf-identity.cloudfront_access_identity_path}"
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "Munki"

  aliases = ["${var.cf_dns_aliases}"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "myS3Origin"

    # We don't actually need this enabled for the default rule
    trusted_signers = "${var.cf_trusted_signers}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 43200
    default_ttl            = 86400
    max_ttl                = 432000
  }

  ordered_cache_behavior {
    path_pattern     = "/icons/*.plist"
    target_origin_id = "myS3Origin"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = false
    smooth_streaming = false

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    trusted_signers        = "${var.cf_trusted_signers}"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 30
    default_ttl            = 120
    max_ttl                = 250
  }

  ordered_cache_behavior {
    path_pattern     = "/catalogs/*"
    target_origin_id = "myS3Origin"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = false
    smooth_streaming = false

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    trusted_signers        = "${var.cf_trusted_signers}"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 30
    default_ttl            = 120
    max_ttl                = 250
  }

  ordered_cache_behavior {
    path_pattern     = "/client_resources/*"
    target_origin_id = "myS3Origin"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = false
    smooth_streaming = false

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    trusted_signers        = "${var.cf_trusted_signers}"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 43200
    default_ttl            = 86400
    max_ttl                = 432000
  }

  ordered_cache_behavior {
    path_pattern     = "/icons/*"
    target_origin_id = "myS3Origin"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = false
    smooth_streaming = false

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    trusted_signers        = "${var.cf_trusted_signers}"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 43200
    default_ttl            = 86400
    max_ttl                = 432000
  }

  ordered_cache_behavior {
    path_pattern     = "/manifests/*"
    target_origin_id = "myS3Origin"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = false
    smooth_streaming = false

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    trusted_signers        = "${var.cf_trusted_signers}"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 30
    default_ttl            = 120
    max_ttl                = 250
  }

  ordered_cache_behavior {
    path_pattern     = "/pkgs/*"
    target_origin_id = "myS3Origin"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = false
    smooth_streaming = false

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    trusted_signers        = "${var.cf_trusted_signers}"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 43200
    default_ttl            = 86400
    max_ttl                = 432000
  }

  ordered_cache_behavior {
    path_pattern     = "/pkgsinfo/*"
    target_origin_id = "myS3Origin"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = false
    smooth_streaming = false

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    trusted_signers        = "${var.cf_trusted_signers}"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 43200
    default_ttl            = 86400
    max_ttl                = 432000
  }

  price_class = "${var.cf_price_class}"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"

  viewer_certificate {
    cloudfront_default_certificate = "${var.cf_default_certificate}"

    acm_certificate_arn      = "${var.cf_ssl_cert_arn}"
    minimum_protocol_version = "${var.cf_minimum_protocol_version}"
    ssl_support_method       = "${var.cf_ssl_support_method}"
  }
}
