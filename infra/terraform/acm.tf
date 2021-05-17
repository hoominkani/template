resource "aws_acm_certificate" "app" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  domain_name = "${var.domain}"

  subject_alternative_names = ["${terraform.workspace == "dev" ? "dev.${var.domain}" : "www.${var.domain}"}"]

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
    #ignore_changes = [
    #  "subject_alternative_names"
    #]
  }
}

resource "aws_acm_certificate" "cdn" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  domain_name = var.domain

  subject_alternative_names = [
    "${terraform.workspace == "dev" ? "dev.${var.domain}" : "www.${var.domain}"}",
  ]

  validation_method = "DNS"
  provider          = "aws.virginia"

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      "subject_alternative_names"
    ]
  }
}
