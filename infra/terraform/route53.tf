resource "aws_route53_record" "www" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    zone_id  = "${var.zone_id}"
    name = "${terraform.workspace == "dev" ? "dev.${var.domain}" : "${var.domain}"}"
    type = "A"
    alias {
        name = "${aws_alb.front[0].dns_name}"
        zone_id = "${aws_alb.front[0].zone_id}"
        evaluate_target_health = true
    }
}

resource "aws_route53_record" "cloudfront_alias" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  zone_id = "${var.zone_id}"
  name = "${terraform.workspace == "dev" ? "dev.cdn.${var.domain}" : "cdn.${var.domain}"}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.assets[count.index].domain_name}"
    zone_id                = "${aws_cloudfront_distribution.assets[count.index].hosted_zone_id}"
    evaluate_target_health = true
  }
}
