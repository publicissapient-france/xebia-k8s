output "aws_elb_api_id" {
    value = "${aws_elb.aws-elb-api.id}"
}

output "aws_elb_api_fqdn" {
    value = "${aws_route53_record.aws-elb-api.fqdn}"
}
