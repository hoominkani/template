# Policy
resource "aws_ecr_repository_policy" "policy-api" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "${aws_ecr_repository.sample-api[0].name}",
            "Effect": "Allow",
            "Principal": {"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sample_deploy_role"},
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
EOF
  repository = "${aws_ecr_repository.sample-api[0].name}"
}

resource "aws_ecr_repository" "sample-api" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  name = "sample/${terraform.workspace}-sample-api"
}

# Policy
resource "aws_ecr_repository_policy" "policy-nginx" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "${aws_ecr_repository.sample-nginx[0].name}",
            "Effect": "Allow",
            "Principal": {"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/sample_deploy_role"},
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
EOF
  repository = "${aws_ecr_repository.sample-nginx[0].name}"
}

resource "aws_ecr_repository" "sample-nginx" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  name = "sample/${terraform.workspace}-sample-nginx"
}

## Privatelink

resource "aws_vpc_endpoint" "ecr-dkr" {
  count = "${terraform.workspace == "dev" ? 1 : 0}"
  service_name      = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  vpc_id = data.terraform_remote_state.super_state.outputs.vpc_id
  subnet_ids        = ["${aws_subnet.private_a[0].id}"]
  private_dns_enabled = true

  security_group_ids = [
    "${aws_security_group.sample_privatelinkt[0].id}",
  ]

  tags = {
    Name        = "ecr-dkr-endpoint-${terraform.workspace}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_vpc_endpoint" "cloudwatch" {
  count = "${terraform.workspace == "dev" ? 1 : 0}"
  vpc_id = data.terraform_remote_state.super_state.outputs.vpc_id
  service_name = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids        = ["${aws_subnet.private_c[0].id}"]
  private_dns_enabled = true

  security_group_ids = [
      "${aws_security_group.sample_privatelinkt[0].id}",
  ]
  tags = {
      Name = "CloudWatch VPC Endpoint Interface - ${terraform.workspace}"
      Environment = "${terraform.workspace}"
    }
}

resource "aws_vpc_endpoint" "s3" {
  count = "${terraform.workspace == "dev" ? 1 : 0}"
  vpc_id = data.terraform_remote_state.super_state.outputs.vpc_id
  service_name      = data.aws_vpc_endpoint_service.s3.service_name
  vpc_endpoint_type = "Gateway"
  route_table_ids = ["${aws_route_table.private_a[0].id}", "${aws_route_table.private_c[0].id}", "${var.pro_private_route_tablec_a}", "${var.pro_private_route_tablec_c}"]

  tags = {
    Name        = "s3-endpoint-${terraform.workspace}"
    Environment = "${terraform.workspace}"
  }
}

data "aws_vpc_endpoint_service" "s3" {
  service = "s3"
}
