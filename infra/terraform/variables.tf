# ----------------------------
# Global
# ----------------------------
variable "project" {
  default = "sample"
}

variable "region" {
  default = "ap-northeast-1"
}

provider "aws" {
  region = "${var.region}"
}

variable "availability_zones" {
  description = "The availability zones"
  default = "ap-northeast-1a,ap-northeast-1c"
}

# ----------------------------
# S3
# ----------------------------
variable "tf_s3_bucket" {
  default = "sample.terraform"
}

# ----------------------------
# State file
# ----------------------------
variable "production_state_file" {
  default = "sample.production.terraform.tfstate"
}

variable "development_state_file" {
  default = "sample.development.terraform.tfstate"
}

variable "super_state_file" {
  default = "sample.super.terraform.tfstate"
}

# ----------------------------
# ECS
# ECS Optimized-instance 2016.03.h
# ----------------------------
variable "ami" {
    # ECS Optimized-instance 2016.03.h
    default =  "ami-2b6ba64a"
}

variable "fargate_cpu" {
  default = 256
}

variable "fargate_memory" {
  default = 512
}

variable "app_port" {
  default = 9000
}

variable "nginx_port" {
  default = 80
}

variable "app_key" {
  # type = "string"
  default = ""
}

# ----------------------------
# Route53
# ----------------------------
variable "domain" {
  default = "sample.jp"
}

variable "zone_id" {
  default = ""
}

# ----------------------------
# RDS
# ----------------------------
variable "db_password" {
  default = ""
}
