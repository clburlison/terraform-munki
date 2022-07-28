resource "aws_cloudfront_origin_access_identity" "cf-identity" {
  comment = "Munki identity"
}

resource "aws_cloudfront_distribution" "munki" {
  count = var.basic_auth_user != "" ? 0 : 1
  origin {
    domain_name = aws_s3_bucket.munki-bucket[0].bucket_domain_name
    origin_id   = "munki"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cf-identity.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = var.name

  aliases = var.cf_dns_aliases

  // All values are defaults from the AWS console.
  default_cache_behavior {
    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = "${aws_lambda_function.basic_auth_lambda[0].arn}:${aws_lambda_function.basic_auth_lambda[0].version}"
    }

    trusted_signers        = var.cf_trusted_signers
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    // This needs to match the `origin_id` above.
    target_origin_id = "munki"
    min_ttl          = var.default_cache_behavior_min_ttl
    default_ttl      = var.default_cache_behavior_default_ttl
    max_ttl          = var.default_cache_behavior_max_ttl

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern = "/catalogs/*"

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = "${aws_lambda_function.basic_auth_lambda[0].arn}:${aws_lambda_function.basic_auth_lambda[0].version}"
    }

    trusted_signers        = var.cf_trusted_signers
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    min_ttl                = var.catalogs_ordered_cache_behavior_min_ttl
    default_ttl            = var.catalogs_ordered_cache_behavior_default_ttl
    max_ttl                = var.catalogs_ordered_cache_behavior_max_ttl
    target_origin_id       = "munki"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern = "/manifests/*"

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = "${aws_lambda_function.basic_auth_lambda[0].arn}:${aws_lambda_function.basic_auth_lambda[0].version}"
    }

    trusted_signers        = var.cf_trusted_signers
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    min_ttl                = var.manifests_ordered_cache_behavior_min_ttl
    default_ttl            = var.manifests_ordered_cache_behavior_default_ttl
    max_ttl                = var.manifests_ordered_cache_behavior_max_ttl
    target_origin_id       = "munki"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern = "/icons/*"

    dynamic "lambda_function_association" {
      for_each = var.enable_icons_basic_auth ? [1] : []
      content {
        event_type   = "viewer-request"
        lambda_arn   = "${aws_lambda_function.basic_auth_lambda[0].arn}:${aws_lambda_function.basic_auth_lambda[0].version}"
      }
    }

    trusted_signers        = var.cf_trusted_signers
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    min_ttl                = var.icons_ordered_cache_behavior_min_ttl
    default_ttl            = var.icons_ordered_cache_behavior_default_ttl
    max_ttl                = var.icons_ordered_cache_behavior_max_ttl
    target_origin_id       = "munki"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  price_class = var.cf_price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )

  viewer_certificate {
    cloudfront_default_certificate = var.cf_default_certificate

    acm_certificate_arn      = var.cf_ssl_cert_arn
    minimum_protocol_version = var.cf_minimum_protocol_version
    ssl_support_method       = var.cf_ssl_support_method
  }
}

resource "aws_cloudfront_distribution" "munki_basic_auth" {
  count = var.basic_auth_user != "" ? 1 : 0
  origin {
    domain_name = aws_s3_bucket.munki-bucket[0].bucket_domain_name
    origin_id   = "munki"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cf-identity.cloudfront_access_identity_path
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = var.name

  aliases = var.cf_dns_aliases

  // All values are defaults from the AWS console.
  default_cache_behavior {
    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = "${aws_lambda_function.basic_auth_lambda[0].arn}:${aws_lambda_function.basic_auth_lambda[0].version}"
    }

    trusted_signers        = var.cf_trusted_signers
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    // This needs to match the `origin_id` above.
    target_origin_id = "munki"
    min_ttl          = var.default_cache_behavior_min_ttl
    default_ttl      = var.default_cache_behavior_default_ttl
    max_ttl          = var.default_cache_behavior_max_ttl

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern = "/catalogs/*"

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = "${aws_lambda_function.basic_auth_lambda[0].arn}:${aws_lambda_function.basic_auth_lambda[0].version}"
    }

    trusted_signers        = var.cf_trusted_signers
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    min_ttl                = var.catalogs_ordered_cache_behavior_min_ttl
    default_ttl            = var.catalogs_ordered_cache_behavior_default_ttl
    max_ttl                = var.catalogs_ordered_cache_behavior_max_ttl
    target_origin_id       = "munki"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern = "/manifests/*"

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = "${aws_lambda_function.basic_auth_lambda[0].arn}:${aws_lambda_function.basic_auth_lambda[0].version}"
    }

    trusted_signers        = var.cf_trusted_signers
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    min_ttl                = var.manifests_ordered_cache_behavior_min_ttl
    default_ttl            = var.manifests_ordered_cache_behavior_default_ttl
    max_ttl                = var.manifests_ordered_cache_behavior_max_ttl
    target_origin_id       = "munki"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern = "/icons/*"

    lambda_function_association {
      event_type = "viewer-request"
      lambda_arn = "${aws_lambda_function.basic_auth_lambda[0].arn}:${aws_lambda_function.basic_auth_lambda[0].version}"
    }

    trusted_signers        = var.cf_trusted_signers
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    min_ttl                = var.icons_ordered_cache_behavior_min_ttl
    default_ttl            = var.icons_ordered_cache_behavior_default_ttl
    max_ttl                = var.icons_ordered_cache_behavior_max_ttl
    target_origin_id       = "munki"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  price_class = var.cf_price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )

  viewer_certificate {
    cloudfront_default_certificate = var.cf_default_certificate

    acm_certificate_arn      = var.cf_ssl_cert_arn
    minimum_protocol_version = var.cf_minimum_protocol_version
    ssl_support_method       = var.cf_ssl_support_method
  }
}
