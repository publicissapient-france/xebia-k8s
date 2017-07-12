resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.public.id}"

  depends_on = [
    "aws_internet_gateway.default",
  ]
}

resource "aws_subnet" "private" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "${cidrsubnet(aws_vpc.main.cidr_block, var.subnet_block_size, 2)}"
  map_public_ip_on_launch = false

  tags {
    Name = "${var.project_name} - private"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags {
    Name = "${var.project_name} - private route table"
  }
}

resource "aws_route_table_association" "private_association" {
  subnet_id = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.private.id}"
}

resource "aws_route53_zone" "private" {
  name = "private"
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "${var.project_name} - private zone"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}
