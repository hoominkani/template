resource "aws_vpc" "sample" {
    count = "${terraform.workspace == "default" ? 1 : 0}"
    cidr_block           = "10.1.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true
    instance_tenancy     = "default"

    tags = {
        Name = "${var.project}"
        Group = "${var.project}"
    }
}

resource "aws_internet_gateway" "sample" {
    count = "${terraform.workspace == "default" ? 1 : 0}"
    vpc_id = "${aws_vpc.sample[0].id}"


    tags = {
        Name = "${var.project}"
        Group = "${var.project}"

    }
}

resource "aws_subnet" "sample_a" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    vpc_id = data.terraform_remote_state.super_state.outputs.vpc_id
    cidr_block = "${terraform.workspace == "dev" ? "10.1.1.0/24" : "10.1.2.0/24"}"
    availability_zone = "${var.region}a"
    map_public_ip_on_launch = true
    tags = {
            Name = "${var.project}-${terraform.workspace}"
            Group = "${var.project}"
    }
}

resource "aws_subnet" "sample_c" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    vpc_id = data.terraform_remote_state.super_state.outputs.vpc_id
    cidr_block = "${terraform.workspace == "dev" ? "10.1.3.0/24" : "10.1.4.0/24"}"
    availability_zone = "${var.region}c"
    map_public_ip_on_launch = true
    tags = {
            Name = "${var.project}-${terraform.workspace}"
            Group = "${var.project}"
    }
}

resource "aws_route_table" "sample" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    vpc_id = data.terraform_remote_state.super_state.outputs.vpc_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = data.terraform_remote_state.super_state.outputs.internet_gateway_id
    }

    tags = {
        Name = "${var.project}-${terraform.workspace}"
        Group = "${var.project}"
    }
}

resource "aws_route_table" "public" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  vpc_id = data.terraform_remote_state.super_state.outputs.vpc_id

  tags = {
      Name = "${var.project}-${terraform.workspace}"
      Group = "${var.project}"
  }
}

resource "aws_route_table_association" "public_a" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    subnet_id = "${aws_subnet.sample_a[0].id}"
    route_table_id = "${aws_route_table.sample[0].id}"
}

resource "aws_route_table_association" "public_c" {
    count = "${terraform.workspace == "default" ? 0 : 1}"
    subnet_id = "${aws_subnet.sample_c[0].id}"
    route_table_id = "${aws_route_table.sample[0].id}"
}

# private

resource "aws_subnet" "private_a" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  vpc_id = data.terraform_remote_state.super_state.outputs.vpc_id
  cidr_block = "${terraform.workspace == "dev" ? "10.1.5.0/24" : "10.1.6.0/24"}"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
  tags = {
          Name = "${var.project}-${terraform.workspace}-private-a"
          Group = "${var.project}"
  }
}
resource "aws_subnet" "private_c" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  vpc_id = data.terraform_remote_state.super_state.outputs.vpc_id
  cidr_block = "${terraform.workspace == "dev" ? "10.1.7.0/24" : "10.1.8.0/24"}"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
  tags = {
          Name = "${var.project}-${terraform.workspace}-private-c"
          Group = "${var.project}"
  }
}

resource "aws_route_table" "private_a" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  vpc_id = data.terraform_remote_state.super_state.outputs.vpc_id

  tags = {
      Name = "${var.project}-${terraform.workspace}"
      Group = "${var.project}"
  }
}
resource "aws_route_table" "private_c" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  vpc_id = data.terraform_remote_state.super_state.outputs.vpc_id

  tags = {
      Name = "${var.project}-${terraform.workspace}"
      Group = "${var.project}"
  }
}

resource "aws_eip" "nat_gateway_a" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  vpc = true

  tags = {
    Name = "${terraform.workspace}_nat_gateway_eip_a"
  }
}

resource "aws_eip" "nat_gateway_c" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  vpc = true

  tags = {
    Name = "${terraform.workspace}_nat_gateway_eip_c"
  }
}

resource "aws_nat_gateway" "private_a" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  allocation_id = "${aws_eip.nat_gateway_a[0].id}"
  subnet_id     = "${aws_subnet.sample_a[0].id}"

  tags = {
    Name = "${terraform.workspace}_nat_gateway_a"
  }
}

resource "aws_nat_gateway" "private_c" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  allocation_id = "${aws_eip.nat_gateway_c[0].id}"
  subnet_id     = "${aws_subnet.sample_c[0].id}"

  tags = {
    Name = "${terraform.workspace}_nat_gateway_c"
  }
}

resource "aws_route" "private_a" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  route_table_id         = aws_route_table.private_a[0].id
  nat_gateway_id         = aws_nat_gateway.private_a[0].id
  destination_cidr_block = "0.0.0.0/0"
}
resource "aws_route" "private_c" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  route_table_id         = aws_route_table.private_c[0].id
  nat_gateway_id         = aws_nat_gateway.private_c[0].id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_a" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  subnet_id      = "${aws_subnet.private_a[0].id}"
  route_table_id = aws_route_table.private_a[0].id
}
resource "aws_route_table_association" "private_c" {
  count = "${terraform.workspace == "default" ? 0 : 1}"
  subnet_id      = "${aws_subnet.private_c[0].id}"
  route_table_id = aws_route_table.private_c[0].id
}
