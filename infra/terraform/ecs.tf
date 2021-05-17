resource "aws_ecs_cluster" "sample" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  name = "${var.project}-${terraform.workspace}"
}

resource "aws_ecs_service" "alb_api" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  name = "alb-api"
  launch_type = "FARGATE"

  cluster = "${aws_ecs_cluster.sample[0].id}"
  task_definition = "${aws_ecs_task_definition.api[0].arn}"
  desired_count = 2
  deployment_minimum_healthy_percent = 5

  load_balancer {
    target_group_arn = "${aws_alb_target_group.web[0].arn}"
    container_name = "nginx"
    container_port = 80
  }

  network_configuration {
    subnets = ["${aws_subnet.private_a[0].id}", "${aws_subnet.private_c[0].id}"]
    security_groups = ["${aws_security_group.sample_web[0].id}"]
    assign_public_ip = true
  }

  #lifecycle {
  #  ignore_changes = ["task_definition"]
  #}
}

resource "aws_ecs_task_definition" "api" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = data.terraform_remote_state.super_state.outputs.instance_role

  #lifecycle {
  #  ignore_changes = ["container_definitions"]
  #}

  family = "${var.project}-${terraform.workspace}-api"
  container_definitions = <<-EOF
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${aws_ecr_repository.sample-nginx[0].repository_url}:latest",
    "memory": ${var.fargate_memory},
    "name": "nginx",
    "essential": true,
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.nginx_port},
        "hostPort": ${var.nginx_port}
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
        "awslogs-group" : "${var.project}-${terraform.workspace}-nginx",
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "nginx"
        }
    },
    "ulimits": [
        {
          "softLimit": 104000,
          "hardLimit": 104000,
          "name": "nofile"
        }
    ]
  },
  {
    "cpu": ${var.fargate_cpu},
    "image": "${aws_ecr_repository.sample-api[0].repository_url}:latest",
    "memory": ${var.fargate_memory},
    "name": "app",
    "essential": true,
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ],
    "environment": [
      {
        "name": "APP_ENV",
        "value": "development"
      },
      {
        "name": "APP_DEBUG",
        "value": "true"
      },
      {
        "name": "LOG_CHANNEL",
        "value": "errorlog"
      },
      {
        "name": "APP_DOMAIN",
        "value": "${terraform.workspace}.${var.domain}"
      },
      {
        "name": "ASSET_URL",
        "value": "${aws_s3_bucket.sample_assets[count.index].bucket_regional_domain_name}"
      },
      {
        "name": "DB_CONNECTION",
        "value": "mysql"
      },
      {
        "name": "DB_HOST",
        "value": "${aws_db_instance.sample[count.index].address}"
      },
      {
        "name": "CDN_URL",
        "value": "${aws_cloudfront_distribution.assets[count.index].domain_name}"
      },
      {
        "name": "DB_PORT",
        "value": "3306"
      },
      {
        "name": "DB_USERNAME",
        "value": "${var.project}"
      },
      {
        "name": "DB_DATABASE",
        "value": "${var.project}"
      },
      {
        "name": "REDIS_HOST",
        "value": "${aws_elasticache_cluster.sample[count.index].cache_nodes.0.address}"
      },
      {
        "name": "CACHE_DRIVER",
        "value": "redis"
      },
      {
        "name": "SESSION_DRIVER",
        "value": "redis"
      },
      {
        "name": "SESSION_LIFETIME",
        "value": "108000"
      },
      {
        "name": "MAIL_DRIVER",
        "value": "ses"
      },
      {
        "name": "MAIL_ENCRYPTION",
        "value": "tls"
      },
      {
        "name": "MAIL_FROM_NAME",
        "value": "${var.project}"
      },
      {
        "name": "MAIL_FROM_ADDRESS",
        "value": "info@mail.${var.domain}"
      },
      {
        "name": "MAIL_FROM_NAME",
        "value": "${var.project}"
      },
      {
        "name": "TELESCOPE_ENABLED",
        "value": "false"
      },
      {
        "name": "DEBUGBAR_ENABLED",
        "value": "false"
      }
    ],
    "secrets": [
      {
        "name": "APP_KEY",
        "valueFrom": "${aws_ssm_parameter.app_key[count.index].arn}"
      },
      {
        "name": "DB_PASSWORD",
        "valueFrom": "${aws_ssm_parameter.db_password[count.index].arn}"
      },
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
        "awslogs-group" : "${var.project}-${terraform.workspace}-api",
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "app"
        }
    }
  }
]
EOF
}

resource "aws_ecs_task_definition" "migrate" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  family = "${var.project}-${terraform.workspace}-migrate"
  execution_role_arn       = data.terraform_remote_state.super_state.outputs.instance_role

  #lifecycle {
  #  ignore_changes = ["container_definitions"]
  #}

  container_definitions = <<-EOF
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${aws_ecr_repository.sample-api[0].repository_url}:latest",
    "memory": ${var.fargate_memory},
    "name": "app",
    "command": ["php", "artisan", "migrate"],
    "essential": true,
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ],
    "environment": [
      {
        "name": "APP_ENV",
        "value": "development"
      },
      {
        "name": "APP_DEBUG",
        "value": "true"
      },
      {
        "name": "APP_DOMAIN",
        "value": "${terraform.workspace}.${var.domain}"
      },
      {
        "name": "ASSET_URL",
        "value": "${aws_s3_bucket.sample_assets[count.index].bucket_regional_domain_name}"
      },
      {
        "name": "LOG_CHANNEL",
        "value": "errorlog"
      },
      {
        "name": "DB_CONNECTION",
        "value": "mysql"
      },
      {
        "name": "DB_HOST",
        "value": "${aws_db_instance.sample[count.index].address}"
      },
      {
        "name": "DB_PORT",
        "value": "3306"
      },
      {
        "name": "DB_USERNAME",
        "value": "${var.project}"
      },
      {
        "name": "DB_DATABASE",
        "value": "${var.project}"
      },
      {
        "name": "REDIS_HOST",
        "value": "${aws_elasticache_cluster.sample[count.index].cache_nodes.0.address}"
      },
      {
        "name": "CACHE_DRIVER",
        "value": "redis"
      },
      {
        "name": "SESSION_DRIVER",
        "value": "redis"
      },
      {
        "name": "SESSION_LIFETIME",
        "value": "86400"
      }
    ],
    "secrets": [
      {
        "name": "APP_KEY",
        "valueFrom": "${aws_ssm_parameter.app_key[count.index].arn}"
      },
      {
        "name": "DB_PASSWORD",
        "valueFrom": "${aws_ssm_parameter.db_password[count.index].arn}"
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
        "awslogs-group" : "${var.project}-${terraform.workspace}-migrate",
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "app"
        }
    }
  }
]
EOF
}

resource "aws_ecs_service" "cron" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  launch_type = "FARGATE"
  name = "cron"
  cluster = "${aws_ecs_cluster.sample[0].id}"
  task_definition = "${aws_ecs_task_definition.cron[0].arn}"
  desired_count = 1
  deployment_minimum_healthy_percent = 100

  network_configuration {
    subnets = ["${aws_subnet.private_a[0].id}", "${aws_subnet.private_c[0].id}"]
    security_groups = ["${aws_security_group.sample_web[0].id}"]
    assign_public_ip = true
  }

  #lifecycle {
  #  ignore_changes = ["task_definition"]
  #}
}

resource "aws_ecs_task_definition" "cron" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  family = "${var.project}-${terraform.workspace}-cron"
  execution_role_arn       = data.terraform_remote_state.super_state.outputs.instance_role

  #lifecycle {
  #  ignore_changes = ["container_definitions"]
  #}

  container_definitions = <<-EOF
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${aws_ecr_repository.sample-api[0].repository_url}:latest",
    "memory": ${var.fargate_memory},
    "name": "cron",
    "entryPoint": ["/bin/sh"],
    "command": ["-c", "echo '* * * * * php /var/www/artisan schedule:run' > /var/spool/cron/crontabs/root && crond -l 2 -f"],
    "essential": true,
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ],
    "environment": [
      {
        "name": "APP_ENV",
        "value": "development"
      },
      {
        "name": "APP_DEBUG",
        "value": "true"
      },
      {
        "name": "APP_DOMAIN",
        "value": "${terraform.workspace}.${var.domain}"
      },
      {
        "name": "ASSET_URL",
        "value": "${aws_s3_bucket.sample_assets[count.index].bucket_regional_domain_name}"
      },
      {
        "name": "LOG_CHANNEL",
        "value": "errorlog"
      },
      {
        "name": "DB_CONNECTION",
        "value": "mysql"
      },
      {
        "name": "DB_HOST",
        "value": "${aws_db_instance.sample[count.index].address}"
      },
      {
        "name": "DB_PORT",
        "value": "3306"
      },
      {
        "name": "DB_USERNAME",
        "value": "${var.project}"
      },
      {
        "name": "DB_DATABASE",
        "value": "${var.project}"
      },
      {
        "name": "REDIS_HOST",
        "value": "${aws_elasticache_cluster.sample[count.index].cache_nodes.0.address}"
      },
      {
        "name": "CACHE_DRIVER",
        "value": "redis"
      },
      {
        "name": "SESSION_DRIVER",
        "value": "redis"
      },
      {
        "name": "SESSION_LIFETIME",
        "value": "86400"
      },
      {
        "name": "MAIL_DRIVER",
        "value": "ses"
      },
      {
        "name": "MAIL_ENCRYPTION",
        "value": "tls"
      },
      {
        "name": "MAIL_FROM_NAME",
        "value": "${var.project}"
      },
      {
        "name": "MAIL_FROM_ADDRESS",
        "value": "info@mail.${var.domain}"
      },
      {
        "name": "MAIL_FROM_NAME",
        "value": "${var.project}"
      }
    ],
    "secrets": [
      {
        "name": "APP_KEY",
        "valueFrom": "${aws_ssm_parameter.app_key[count.index].arn}"
      },
      {
        "name": "DB_PASSWORD",
        "valueFrom": "${aws_ssm_parameter.db_password[count.index].arn}"
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
        "awslogs-group" : "${var.project}-${terraform.workspace}-cron",
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "cron"
        }
    }
  }
]
EOF
}

resource "aws_ecs_service" "queue" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  launch_type = "FARGATE"
  name = "queue"
  cluster = "${aws_ecs_cluster.sample[0].id}"
  task_definition = "${aws_ecs_task_definition.queue[0].arn}"
  desired_count = 0
  deployment_minimum_healthy_percent = 100


  network_configuration {
    subnets = ["${aws_subnet.private_a[0].id}", "${aws_subnet.private_c[0].id}"]
    security_groups = ["${aws_security_group.sample_web[0].id}"]
    assign_public_ip = true
  }

  #lifecycle {
  #  ignore_changes = ["task_definition"]
  #}
}

resource "aws_ecs_task_definition" "queue" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  family = "${var.project}-${terraform.workspace}-queue"
  execution_role_arn       = data.terraform_remote_state.super_state.outputs.instance_role

  #lifecycle {
  #  ignore_changes = ["container_definitions"]
  #}

  container_definitions = <<-EOF
[
  {
    "cpu": ${var.fargate_cpu},
    "image": "${aws_ecr_repository.sample-api[0].repository_url}:latest",
    "memory": ${var.fargate_memory},
    "name": "cron",
    "entryPoint": ["/bin/sh"],
    "command": ["-c", "php artisan queue:work --daemon --delay=1 --tries=10"],
    "essential": true,
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": ${var.app_port},
        "hostPort": ${var.app_port}
      }
    ],
    "environment": [
      {
        "name": "APP_ENV",
        "value": "development"
      },
      {
        "name": "APP_DEBUG",
        "value": "true"
      },
      {
        "name": "APP_DOMAIN",
        "value": "${terraform.workspace}.${var.domain}"
      },
      {
        "name": "ASSET_URL",
        "value": "${aws_s3_bucket.sample_assets[count.index].bucket_regional_domain_name}"
      },
      {
        "name": "LOG_CHANNEL",
        "value": "errorlog"
      },
      {
        "name": "DB_CONNECTION",
        "value": "mysql"
      },
      {
        "name": "DB_HOST",
        "value": "${aws_db_instance.sample[count.index].address}"
      },
      {
        "name": "DB_PORT",
        "value": "3306"
      },
      {
        "name": "DB_USERNAME",
        "value": "${var.project}"
      },
      {
        "name": "DB_DATABASE",
        "value": "${var.project}"
      },
      {
        "name": "REDIS_HOST",
        "value": "${aws_elasticache_cluster.sample[count.index].cache_nodes.0.address}"
      },
      {
        "name": "CACHE_DRIVER",
        "value": "redis"
      },
      {
        "name": "SESSION_DRIVER",
        "value": "redis"
      },
      {
        "name": "SESSION_LIFETIME",
        "value": "86400"
      },
      {
        "name": "MAIL_DRIVER",
        "value": "ses"
      },
      {
        "name": "MAIL_ENCRYPTION",
        "value": "tls"
      },
      {
        "name": "MAIL_FROM_NAME",
        "value": "${var.project}"
      },
      {
        "name": "MAIL_FROM_ADDRESS",
        "value": "info@mail.${var.domain}"
      },
      {
        "name": "MAIL_FROM_NAME",
        "value": "${var.project}"
      }
    ],
    "secrets": [
      {
        "name": "APP_KEY",
        "valueFrom": "${aws_ssm_parameter.app_key[count.index].arn}"
      },
      {
        "name": "DB_PASSWORD",
        "valueFrom": "${aws_ssm_parameter.db_password[count.index].arn}"
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
        "awslogs-group" : "${var.project}-${terraform.workspace}-queue",
        "awslogs-region": "ap-northeast-1",
        "awslogs-stream-prefix": "queue"
        }
    }
  }
]
EOF
}
