resource "aws_cloudfront_distribution" "blog" {
  origin {
    domain_name = "${aws_s3_bucket.blog.id}.s3.amazonaws.com"
    origin_id   = "s3"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.blog.cloudfront_access_identity_path}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  logging_config {
    bucket = "mrgossett-logs.s3.amazonaws.com"
    prefix = "blog/cloudfront/"
  }

  aliases = ["blog.mrgossett.com", "mrgossett.com"]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA"]
    }
  }

  viewer_certificate {
    minimum_protocol_version = "TLSv1"
    ssl_support_method       = "sni-only"
    acm_certificate_arn      = "${data.aws_acm_certificate.mrg.arn}"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 404
    response_page_path = "/404.html"
  }
}

resource "aws_cloudfront_origin_access_identity" "blog" {
  comment = "OAI for blog"
}

data "aws_acm_certificate" "mrg" {
  domain   = "mrgossett.com"
  statuses = ["ISSUED"]
}

data "aws_caller_identity" "current" {}
