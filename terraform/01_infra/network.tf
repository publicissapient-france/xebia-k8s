
resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = true

  tags {
    Name  = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_eip" "nat" {}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.private.id}"

  depends_on = [
    "aws_internet_gateway.default",
  ]
}

/* Routing table for public subnet */
resource "aws_route_table" "main" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default.id}"
  }

  tags {
    Name  = "${var.project_name} - main route table"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = "${aws_vpc.main.id}"
  route_table_id = "${aws_route_table.main.id}"
}

/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.project_name} - gateway"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.main.cidr_block, var.subnet_block_size, 1)}"
  map_public_ip_on_launch = true

  depends_on = [
    "aws_internet_gateway.default",
  ]

  tags {
    Name  = "${var.project_name} - public"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, var.subnet_block_size, 2)}"
  map_public_ip_on_launch = false

  tags {
    Name  = "${var.project_name} - private"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_route53_zone" "private" {
  name   = "private"
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name  = "${var.project_name} - private zone"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}
