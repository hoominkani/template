resource "aws_cloudwatch_log_group" "sample-nginx" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  name = "${var.project}-${terraform.workspace}-nginx"
  retention_in_days = "${terraform.workspace == "dev" ? 5 : 30}"
}

resource "aws_cloudwatch_log_group" "sample-app" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  name = "${var.project}-${terraform.workspace}-api"
  retention_in_days = "${terraform.workspace == "dev" ? 5 : 30}"
}

resource "aws_cloudwatch_log_group" "sample-cron" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  name = "${var.project}-${terraform.workspace}-cron"
  retention_in_days = "${terraform.workspace == "dev" ? 5 : 30}"
}

resource "aws_cloudwatch_log_group" "sample-queue" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  name = "${var.project}-${terraform.workspace}-queue"
  retention_in_days = "${terraform.workspace == "dev" ? 5 : 30}"
}

resource "aws_cloudwatch_log_group" "sample-migrate" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  name = "${var.project}-${terraform.workspace}-migrate"
  retention_in_days = "${terraform.workspace == "dev" ? 5 : 30}"
}
