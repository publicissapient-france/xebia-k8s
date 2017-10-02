resource "aws_instance" "master" {
  count = "3"
  subnet_id = "${data.terraform_remote_state.infra.private_subnet}"
  ami = "${var.ami}"

  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.default.key_name}"

  # security group name here
  vpc_security_group_ids = [
    "${aws_security_group.allow_bastion.id}",
    "${aws_security_group.allow_elb.id}"
  ]
  iam_instance_profile = "${aws_iam_instance_profile.kube-master.id}"
  provisioner "remote-exec" {
    inline = "sleep 1"

    connection {
      user = "ubuntu"
      private_key = "${file("ssh/rsakey")}"
      bastion_host = "${var.bastion_ip}"
    }
  }

  tags {
    Name = "${var.project_name} - main ${count.index + 1}"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

resource "aws_elb" "master" {
  subnets = [
    "${data.terraform_remote_state.infra.public_subnet}"
  ]

  "listener" {
    instance_port = 6443
    instance_protocol = "tcp"
    lb_port = 6443
    lb_protocol = "tcp"
  }
  instances = [
    "${aws_instance.master.0.id}",
    "${aws_instance.master.1.id}"
  ]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:6443"
    interval            = 30
  }

  tags {
    Name = "${var.project_name} - elb"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
  security_groups = ["${aws_security_group.allow_elb.id}"]
}


resource "aws_route53_record" "master-dns" {
  zone_id = "${data.aws_route53_zone.public_dns.id}"
  name = "master.${var.public_subdomain}.${var.public_domain}"
  type = "CNAME"
  ttl = "300"

  records = [
    "${aws_elb.master.dns_name}",
  ]
}
