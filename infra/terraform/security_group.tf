resource "aws_security_group" "sample_web" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    name = "${var.project}-${terraform.workspace}-web"
    description = "security group for ${var.project} web"
    vpc_id = data.terraform_remote_state.super_state.outputs.vpc_id

    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    # HTTP access from anywhere
    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "sample_db" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    name = "${var.project}-${terraform.workspace}-db"
    description = "security group for ${var.project} db"
    vpc_id = data.terraform_remote_state.super_state.outputs.vpc_id

    ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      cidr_blocks = ["10.1.0.0/16"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_security_group" "sample_elb" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    name = "${var.project}-${terraform.workspace}-elb"
    description = "security group for ${var.project} elb"
    vpc_id = data.terraform_remote_state.super_state.outputs.vpc_id

    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "sample_elasticache" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    name = "${var.project}-${terraform.workspace}-elasticache"
    description = "security group for ${var.project} elasticache"
    vpc_id = data.terraform_remote_state.super_state.outputs.vpc_id

    ingress {
      from_port = 6379
      to_port = 6379
      protocol = "tcp"
      cidr_blocks = [data.terraform_remote_state.super_state.outputs.vpc_cidr_block]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "sample_alb" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    name = "${var.project}-${terraform.workspace}-alb"
    description = "security group for ${var.project} alb"
    vpc_id = data.terraform_remote_state.super_state.outputs.vpc_id

    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "bastion" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  name        = "${terraform.workspace}-bastion"
  description = "security group for bastion host (${terraform.workspace})"
  vpc_id      = data.terraform_remote_state.super_state.outputs.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.sample_db[0].id]
  }

  egress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.sample_elasticache[0].id]
  }

  tags = {
    Name = "${var.project}-${terraform.workspace}-sg-bastion"
  }
}

resource "aws_security_group" "sample_privatelinkt" {
    count = "${terraform.workspace == "dev" ? 1 : 0}"
    name = "${var.project}-${terraform.workspace}-privatelink"
    description = "security group for ${var.project} ecr privatelink"
    vpc_id = data.terraform_remote_state.super_state.outputs.vpc_id

    ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = [data.terraform_remote_state.super_state.outputs.vpc_cidr_block]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [data.terraform_remote_state.super_state.outputs.vpc_cidr_block]
    }
}
