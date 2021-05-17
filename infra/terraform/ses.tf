resource "aws_ses_domain_identity" "main" {
  count    = "${terraform.workspace == "default" ? 1 : 0}"
  provider = aws.virginia
  domain   = var.domain
}

resource "aws_ses_domain_identity_verification" "ses_identify_verification" {
  count    = "${terraform.workspace == "default" ? 1 : 0}"
  provider = aws.virginia
  domain   = aws_ses_domain_identity.main[0].id
  depends_on = [aws_route53_record.ses_verification_record]
}

resource "aws_ses_domain_dkim" "domain_dkim" {
  count    = "${terraform.workspace == "default" ? 1 : 0}"
  provider = aws.virginia
  domain   = aws_ses_domain_identity.main[0].domain
}

resource "aws_route53_record" "ses_verification_record" {
  count    = "${terraform.workspace == "default" ? 1 : 0}"
  zone_id  = "${var.zone_id}"
  name     = "_amazonses.${aws_ses_domain_identity.main[0].id}"
  type     = "TXT"
  ttl      = "600"
  records  = ["${aws_ses_domain_identity.main[0].verification_token}"]
}

resource "aws_route53_record" "ses_amazonses_verification_record" {
  count    = "${terraform.workspace == "default" ? 3 : 0}"
  zone_id  = "${var.zone_id}"
  name     = "${element(aws_ses_domain_dkim.domain_dkim[0].dkim_tokens, count.index)}._domainkey.${var.domain}"
  type     = "CNAME"
  ttl      = "600"
  records  = ["${element(aws_ses_domain_dkim.domain_dkim[0].dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_ses_domain_mail_from" "sample" {
  count    = "${terraform.workspace == "default" ? 1 : 0}"
  provider = aws.virginia
  domain           = aws_ses_domain_identity.main[0].domain
  mail_from_domain = "mail.${aws_ses_domain_identity.main[0].domain}"
}

resource "aws_route53_record" "main_ses_domain_mail_from_mx" {
  count    = "${terraform.workspace == "default" ? 1 : 0}"
  zone_id = "${var.zone_id}"
  name    = aws_ses_domain_mail_from.sample[0].mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.us-east-1.amazonses.com"]
}

resource "aws_route53_record" "main_ses_domain_mail_from_txt" {
  count    = "${terraform.workspace == "default" ? 1 : 0}"
  zone_id = "${var.zone_id}"
  name    = aws_ses_domain_mail_from.sample[0].mail_from_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}
