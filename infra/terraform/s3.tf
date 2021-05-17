/*
resource "aws_s3_bucket" "sample_terraform" {
    count = "${terraform.workspace == "default" ? 1 : 0}"
    bucket = "${var.project}.terraform"

    tags = {
        Name = "${var.project}"
        Group = "${var.project}"
    }
}
*/

resource "aws_s3_bucket" "sample_ecs" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    bucket = "${var.project}.${terraform.workspace}.ecs"

    tags = {
        Name = "${var.project}"
        Group = "${var.project}"
    }
}

resource "aws_s3_bucket_object" "nginx_conf" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    bucket = "${aws_s3_bucket.sample_ecs[0].id}"
    key = "nginx.conf"
    source = "files/nginx.conf"
    etag = "${md5(file("files/nginx.conf"))}"
}

resource "aws_s3_bucket" "sample_assets" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    bucket = "${var.project}.${terraform.workspace}.assets"
    force_destroy = true
    acl = "public-read"

    tags = {
        Name = "${var.project}"
        Group = "${var.project}"
    }
}

resource "aws_s3_bucket" "sample_logs" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    bucket = "${var.project}.${terraform.workspace}.logs"
    acl = "authenticated-read"
    force_destroy = true
    policy = <<EOL
{
  "Id": "",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "arn:aws:iam::582318560864:root"
        ]
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${var.project}.${terraform.workspace}.logs/${var.project}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    }
  ]
}
EOL

    tags = {
        Name = "${var.project}"
        Group = "${var.project}"
    }

    #lifecycle {
    #    ignore_changes = ["policy"]
    #}
}
