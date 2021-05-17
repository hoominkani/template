# ----------------------
# Global
# ----------------------

terraform {
  backend "s3" {
    bucket  = "sample.terraform"
    key     = "sample.super.terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "development_state" {
  backend = "s3"
  config = {
    bucket = "${var.tf_s3_bucket}"
    region = "${var.region}"
    key = "${var.development_state_file}"
    encrypt = true
  }
}

data "terraform_remote_state" "production_state" {
  count = "${terraform.workspace == "default" ? 1 : 0}"
  backend = "local"
  config = {
    path = ".terraform/pro/terraform.tfstate"
  }
  /*
  backend = "s3"
  config = {
    bucket = "${var.tf_s3_bucket}"
    region = "${var.region}"
    key = "${var.production_state_file}"
    encrypt = true
  }
  */
}


data "aws_caller_identity" "current" {}

data "aws_ami" "ecs_optimized_ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["*ecs-optimized*"]
  }
  name_regex = "^amzn-ami-.*-amazon-ecs-optimized$"
  owners = ["amazon"]
}

# ----------------------
# Local
# ----------------------

data "terraform_remote_state" "super_state" {
  backend = "s3"
  config = {
    bucket = "${var.tf_s3_bucket}"
    region = "${var.region}"
    key = "${var.super_state_file}"
  }
}
