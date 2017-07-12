resource "aws_key_pair" "default" {
  public_key = "${file("ssh/rsakey.pub")}"
}

resource "aws_instance" "bastion" {
  subnet_id = "${data.terraform_remote_state.infra.public_subnet}"
  ami       = "${var.bastion_ami}"

  instance_type = "t2.nano"
  key_name      = "${aws_key_pair.default.key_name}"

  # security group name here
  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}",
  ]

  provisioner "remote-exec" {
    inline = "sleep 1"

    connection {
      user        = "ubuntu"
      private_key = "${file("ssh/rsakey")}"
    }
  }

  tags {
    Name    = "${var.project_name} - bastion"
    Group   = "${var.project_name}"
    Owner   = "${var.owner}"
    Profile = "client"
  }
}

data "aws_route53_zone" "public_dns" {
  name = "${var.public_domain}"
}

resource "aws_route53_record" "bastion-dns" {
  zone_id = "${data.aws_route53_zone.public_dns.id}"
  name    = "bastion.${var.public_subdomain}.${var.public_domain}"
  type    = "A"
  ttl     = "300"

  records = [
    "${aws_instance.bastion.public_ip}",
  ]
}
