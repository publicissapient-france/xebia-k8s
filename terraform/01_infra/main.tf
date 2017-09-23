provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "default" {
  public_key = "${file("ssh/rsakey.pub")}"
}

resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name  = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "${var.project_name} - gateway"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
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


resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
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
