output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "region" {
  value = "${var.region}"
}

output "public_subnet" {
  value = "${aws_subnet.public.id}"
}

output "private_subnet" {
  value = "${aws_subnet.private.id}"
}


output "nat_addr" {
  value = "${aws_nat_gateway.nat.public_ip}"
}
