output "instance_role_policy" {
  value = "${terraform.workspace == "default" ? aws_iam_role_policy.sample_deploy_role_policy[0].name : ""}"
}

output "instance_role" {
  value = "${terraform.workspace == "default" ? aws_iam_role.sample_deploy_role[0].arn : ""}"
}

output "vpc_id" {
  value = "${terraform.workspace == "default" ? aws_vpc.sample[0].id : ""}"
}

output "vpc_cidr_block" {
  value = "${terraform.workspace == "default" ? aws_vpc.sample[0].cidr_block : ""}"
}

output "app_repository_url" {
  value = "${terraform.workspace == "default" ? aws_ecr_repository.sample-api[0].repository_url : ""}"
}

output "kms_id" {
  value = "${terraform.workspace == "default" ? aws_kms_key.application[0].id : ""}"
}

output "internet_gateway_id" {
  value = "${terraform.workspace == "default" ? aws_internet_gateway.sample[0].id : ""}"
}
