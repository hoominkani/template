resource "aws_ssm_parameter" "app_key" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  name        = "/${terraform.workspace}/app/app_key"
  description = "The parameter for application key"
  key_id      = "${data.terraform_remote_state.super_state.outputs.kms_id}"
  type        = "SecureString"
  value       = "${var.app_key}"

  tags = {
    environment = "${terraform.workspace}"
  }
}

resource "aws_ssm_parameter" "db_password" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  name        = "/${terraform.workspace}/app/db_password"
  description = "The parameter for mysql master password"
  key_id      = "${data.terraform_remote_state.super_state.outputs.kms_id}"
  type        = "SecureString"
  value       = "${var.db_password}"

  tags = {
    environment = "${terraform.workspace}"
  }
}
