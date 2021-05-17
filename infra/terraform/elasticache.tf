resource "aws_elasticache_cluster" "sample" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    cluster_id           = "${var.project}-${terraform.workspace}"
    engine               = "redis"
    engine_version       = "2.8.24"
    node_type            = "cache.t2.micro"
    port                 = 6379
    num_cache_nodes      = 1
    parameter_group_name = "default.redis2.8"
    subnet_group_name    = "${aws_elasticache_subnet_group.sample[0].name}"
    security_group_ids   = ["${aws_security_group.sample_elasticache[0].id}"]
}

resource "aws_elasticache_parameter_group" "sample" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    name = "${var.project}-${terraform.workspace}-cache-params"
    family = "redis2.8"
    description = "Cache cluster default param group"

    parameter {
        name = "activerehashing"
        value = "yes"
    }

    parameter {
        name = "min-slaves-to-write"
        value = "2"
    }
}

resource "aws_elasticache_subnet_group" "sample" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    name        = "${var.project}-${terraform.workspace}"
    description = "${var.project} CacheSubnetGroup"
    subnet_ids  = ["${aws_subnet.sample_a[0].id}", "${aws_subnet.sample_c[0].id}"]
}
