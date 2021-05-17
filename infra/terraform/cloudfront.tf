resource "aws_cloudfront_distribution" "assets" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  origin {
    domain_name = "${var.project}.${terraform.workspace}.assets.s3.amazonaws.com"
    origin_id   = "${var.project}_${terraform.workspace}_assets"
    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.asset_origin_access_identity[0].cloudfront_access_identity_path}"
    }
  }
  enabled = true
  comment = "For ${var.project} Asset files(${terraform.workspace})"
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  default_cache_behavior {
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true
    target_origin_id = "${var.project}_${terraform.workspace}_assets"
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

  }
  depends_on = ["aws_s3_bucket.sample_assets"]
}

resource "aws_cloudfront_origin_access_identity" "asset_origin_access_identity" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  comment = "${var.project} origin access identity for asset files"
}
