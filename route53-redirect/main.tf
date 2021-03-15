resource "aws_s3_bucket" "static_bucket" {
  bucket = var.domain
  website {
    redirect_all_requests_to = var.redirect_url
  }
}

resource "aws_route53_record" "record" {
  zone_id = var.zone_id
  name    = var.domain
  type    = "A"

  alias {
    zone_id                = aws_s3_bucket.static_bucket.hosted_zone_id
    name                   = aws_s3_bucket.static_bucket.website_domain
    evaluate_target_health = false
  }
}
