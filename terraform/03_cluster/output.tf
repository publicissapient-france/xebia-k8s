output "masters" {
  value = ["${aws_instance.master.*.private_ip}"]
}

output "nodes" {
  value = ["${aws_instance.node.*.private_ip}"]
}

output "elb-master" {
  value = "${aws_elb.master.dns_name}"
}
