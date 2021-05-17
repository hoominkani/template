resource "aws_iam_user" "ci" {
    count = "${terraform.workspace == "default" ? 1 : 0}"
    name = "${var.project}-ci"
}

resource "aws_iam_access_key" "ci" {
    count = "${terraform.workspace == "default" ? 1 : 0}"
    user = "${aws_iam_user.ci[0].name}"
}

resource "aws_iam_instance_profile" "sample_deploy_role" {
    count = "${terraform.workspace == "default" ? 1 : 0}"
    name = "${var.project}_deploy_role"
    role = "${aws_iam_role.sample_deploy_role[0].name}"
}

resource "aws_iam_role" "sample_deploy_role" {
    count = "${terraform.workspace == "default" ? 1 : 0}"
    name = "${var.project}_deploy_role"
    path = "/"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": ["ec2.amazonaws.com", "ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "ci-attach" {
  count = "${terraform.workspace == "default" ? 1 : 0}"
  user       = aws_iam_user.ci[0].name
  policy_arn = aws_iam_policy.ci_policy[0].arn
}

resource "aws_iam_policy" "ci_policy" {
  count = "${terraform.workspace == "default" ? 1 : 0}"
  name        = "${var.project}-ci"
  path        = "/"
  description = "ci policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecs:List*",
        "ecs:Describe*",
        "ecs:RegisterTaskDefinition",
        "ecs:DeregisterTaskDefinition",
        "ecs:UpdateService"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ecs:Start*",
        "ecs:Run*",
        "ecs:Stop*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "iam:PassRole"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      "Resource": [
        "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/dev/app/app_key",
        "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/dev/app/db_password",
        "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/pro/app/app_key",
        "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/pro/app/db_password",
        "arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.application[0].key_id}"
      ]
    },
    {
      "Sid": "",
      "Action": [
        "s3:ListBucket",
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObjectAcl",
        "s3:GetObjectAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${var.project}.dev.*",
        "arn:aws:s3:::${var.project}.pro.*"
      ]
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "ses:SendRawEmail",
        "ses:SendEmail"
      ],
      "Resource": "*"
    },
    {
      "Sid": "",
      "Action": [
        "cloudfront:CreateInvalidation",
        "cloudfront:GetInvalidation",
        "cloudfront:ListInvalidations"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": [
          "sns:*",
          "SNS:CreatePlatformEndpoint"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "sample_deploy_role_policy" {
    count = "${terraform.workspace == "default" ? 1 : 0}"
    name = "${var.project}_deploy_role_policy"
    role = "${aws_iam_role.sample_deploy_role[0].id}"
    policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "ecs:List*",
          "ecs:Describe*",
          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition"
        ],
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        "Action": [
          "ecs:Start*",
          "ecs:Run*",
          "ecs:Stop*"
        ],
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        "Action": [
          "ec2:Describe*"
        ],
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        "Sid": "",
        "Effect": "Allow",
        "Action": [
          "ses:SendRawEmail",
          "ses:SendEmail"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "ssm:GetParameters",
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ],
        "Resource": [
          "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/dev/app/app_key",
          "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/dev/app/db_password",
          "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/pro/app/app_key",
          "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/pro/app/db_password",
          "arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.application[0].key_id}"
        ]
      },
      {
        "Sid": "",
        "Action": [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObjectAcl",
          "s3:GetObjectAcl"
        ],
        "Effect": "Allow",
        "Resource": [
          "arn:aws:s3:::${var.project}.dev.*",
          "arn:aws:s3:::${var.project}.pro.*"
        ]
      },
      {
        "Sid": "",
        "Action": [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation",
          "cloudfront:ListInvalidations"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}
