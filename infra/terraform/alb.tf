resource "aws_alb" "front" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  name            = "${var.project}-${terraform.workspace}-alb"
  internal        = false
  security_groups = ["${aws_security_group.sample_alb[0].id}"]
  subnets         = ["${aws_subnet.sample_a[0].id}", "${aws_subnet.sample_c[0].id}"]

  enable_deletion_protection = true

  access_logs {
    bucket = "${aws_s3_bucket.sample_logs[0].bucket}"
    prefix = "${var.project}"
  }

  tags = {
    Group = "${var.project}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_alb_target_group" "web" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  name     = "${var.project}-${terraform.workspace}-tg-web"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.super_state.outputs.vpc_id
  target_type = "ip"

  stickiness {
    type = "lb_cookie"
  }

  health_check {
    path = "/api/healthcheck"
  }

  tags = {
    Group = "${var.project}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_alb_listener" "front_80" {
   count = "${terraform.workspace == "default" ? 0 : 1}"
   load_balancer_arn = "${aws_alb.front[0].arn}"
   port = "80"
   protocol = "HTTP"
   default_action {
     target_group_arn = "${aws_alb_target_group.web[0].arn}"
     type = "forward"
   }
}

resource "aws_lb_listener" "front_443" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  load_balancer_arn = "${aws_alb.front[0].arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_acm_certificate.app[count.index].arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.web[0].arn}"
  }
}

resource "aws_lb_listener_rule" "http_to_https" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  listener_arn = "${aws_alb_listener.front_80[0].arn}"

  priority = 99

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["${terraform.workspace == "dev" ? "dev.${var.domain}" : "${var.domain}"}"]
    }
  }
}

resource "aws_lb_listener_certificate" "front_https" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  listener_arn    = "${aws_lb_listener.front_443[0].arn}"
  certificate_arn = "${aws_acm_certificate.app[0].arn}"
}
