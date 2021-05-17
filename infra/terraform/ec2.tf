module "terraform-aws-bastion-ssm-iam" {
  source = "./modules/terraform-aws-bastion-ssm-iam"

  # The name used to interpolate in the resources, defaults to bastion-ssm-iam
  name = "${var.project}-${terraform.workspace}-bastion"

  environment = "${terraform.workspace}"

  instance_type = "t3.nano"

  # The vpc id
  vpc_id = data.terraform_remote_state.super_state.outputs.vpc_id

  # subnet_ids designates the subnets where the bastion can reside
  subnet_ids = [aws_subnet.sample_a[0].id, aws_subnet.sample_c[0].id]

  # The module creates a security group for the bastion by default
  create_security_group = false

  # The module can create a diffent ssm document for this deployment, to allow
  # different security models per BASTION deployment
  create_new_ssm_document = false

  # It is possible to attach other security groups to the bastion.
  security_group_ids = [aws_security_group.bastion[0].id]

  log_retention = 365
}
