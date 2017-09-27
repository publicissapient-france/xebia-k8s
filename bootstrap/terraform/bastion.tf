data "template_file" "bastion_tpl" {
  template = "${file("userdata/bastion.tpl")}"

  vars {
    ansible_version = "${var.ansible_version}"
    terraform_version ="${var.terraform_version}"
    kubespray_version = "${var.kubespray_version}"
    kubectl_version = "${var.kubectl_version}"
  }
}

resource "aws_instance" "bastion" {
  subnet_id = "${aws_subnet.public.id}"
  ami       = "${var.ami}"

  instance_type = "t2.nano"
  key_name      = "${aws_key_pair.default.key_name}"

  # security group name here
  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}",
  ]

  user_data = "${data.template_file.bastion_tpl.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.bastion.id}"

  tags {
    Name    = "${var.project_name} - bastion"
    Group   = "${var.project_name}"
    Owner   = "${var.owner}"
    Profile = "client"
  }
}

resource "aws_security_group" "ssh" {
  vpc_id      = "${aws_vpc.main.id}"
  name_prefix = "${var.project_name}-sg"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags {
    Name  = "${var.project_name} - allow ssh"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}

// DNS

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
