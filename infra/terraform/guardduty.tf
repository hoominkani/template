resource "aws_guardduty_detector" "guardduty" {
  count = "${terraform.workspace == "default" ? 1 : 0}"
  enable                       = true
  finding_publishing_frequency = "FIFTEEN_MINUTES"
}
