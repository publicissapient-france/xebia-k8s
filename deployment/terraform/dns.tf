data "aws_route53_zone" "public_dns" {
  name = "${var.public_domain}"
}
