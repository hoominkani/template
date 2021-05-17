resource "aws_kms_key" "application" {
  count = "${terraform.workspace == "default" ? 1 : 0}"
  description = "A key to encrypt sensitive data in application"
}
