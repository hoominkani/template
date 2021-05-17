resource "aws_wafregional_ipset" "ipset" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  name = "${var.project}${terraform.workspace}IPSet"

  ip_set_descriptor {
    type  = "IPV4"
    value = ""
  }

  ip_set_descriptor {
    type  = "IPV4"
    value = ""
  }

  ip_set_descriptor {
    type  = "IPV4"
    value = "${data.terraform_remote_state.super_state.outputs.vpc_cidr_block}"
  }
}

resource "aws_wafregional_rule" "wafrule" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  name        = "${var.project}${terraform.workspace}WAFRule"
  metric_name = "${var.project}${terraform.workspace}WAFRule"

  predicate {
    data_id = "${aws_wafregional_ipset.ipset[0].id}"
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_web_acl" "wafacl" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  name        = "${var.project}${terraform.workspace}WebACL"
  metric_name = "${var.project}${terraform.workspace}WebACL"

  default_action {
    type = "ALLOW"
  }

  rule {
    action {
      type = "ALLOW"
    }

    priority = 1
    rule_id  = "${aws_wafregional_rule.wafrule[count.index].id}"
    type     = "REGULAR"
  }
}

resource "aws_wafregional_web_acl_association" "alb" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  resource_arn = "${aws_alb.front[count.index].arn}"
  web_acl_id = "${aws_wafregional_web_acl.wafacl[0].id}"
}
