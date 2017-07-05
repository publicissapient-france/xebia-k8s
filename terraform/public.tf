resource "aws_subnet" "main" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.main.cidr_block, 8, 1)}"
  map_public_ip_on_launch = true

  depends_on = [
    "aws_internet_gateway.default",
  ]

  tags {
    Name  = "${var.project_name} - main"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}
