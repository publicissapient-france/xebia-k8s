output "bastion_addr" {
  value = "${aws_instance.bastion.public_ip}"
}

output "bastion_sg" {
  value = "${aws_security_group.ssh.id}"
}

output "key_name" {
  value = "${aws_key_pair.default.key_name}"
}
