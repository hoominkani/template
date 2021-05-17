resource "aws_db_instance" "sample" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    identifier                = "${var.project}-${terraform.workspace}"
    allocated_storage         = "${terraform.workspace == "dev" ? 20 : 40}"
    storage_type              = "gp2"
    engine                    = "mysql"
    engine_version            = "5.7.17"
    instance_class            = "db.t2.micro"
    name                      = "${var.project}"
    username                  = "${var.project}"
    password                  = "${var.db_password}"
    port                      = 3306
    publicly_accessible       = false
    security_group_names      = []
    vpc_security_group_ids    = ["${aws_security_group.sample_db[0].id}"]
    db_subnet_group_name      = "${aws_db_subnet_group.sample[0].id}"
    parameter_group_name      = "${aws_db_parameter_group.sample[0].name}"
    multi_az                  = false
    backup_retention_period   = 0
    backup_window             = "05:20-05:50"
    maintenance_window        = "sun:04:00-sun:04:30"
    final_snapshot_identifier = "${var.project}-${terraform.workspace}-final"

    tags = {
      Name = "${var.project}-${terraform.workspace}"
      Group = "${var.project}"
    }
}

resource "aws_db_subnet_group" "sample" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    name = "${var.project}-${terraform.workspace}"
    description = "${var.project} group of subnets"
    subnet_ids = ["${aws_subnet.sample_a[0].id}", "${aws_subnet.sample_c[0].id}"]
    tags = {
        Name = "${var.project} DB subnet group"
    }
}

resource "aws_db_parameter_group" "sample" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    name = "${var.project}-${terraform.workspace}-pg"
    family = "mysql5.7"
    description = "RDS parameter group for ${var.project}"

    parameter {
      name = "character_set_server"
      value = "utf8"
    }

    parameter {
      name = "character_set_client"
      value = "utf8"
    }

    parameter {
        name = "max_connections"
        value = 200
    }

    parameter {
      name = "slow_query_log"
      value = 1
    }
}
