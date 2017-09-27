data "template_file" "bastion_tpl" {
  template = "${file("terraform/01_infra/userdata/bastion.tpl")}"

  vars {
    vpn_psk = "${var.vpn_psk}"
    vpn_password ="${var.vpn_password}"
    vpn_user = "${var.vpn_user}"
  }
}

resource "aws_instance" "bastion" {
  subnet_id = "${aws_subnet.public.id}"
  ami       = "${var.bastion_ami}"

  instance_type = "t2.nano"
  key_name      = "${aws_key_pair.default.key_name}"

  # security group name here
  vpc_security_group_ids = [
    "${aws_security_group.ssh.id}",
  ]

  user_data = "${data.template_file.bastion_tpl.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.bastion.id}"
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

resource "aws_iam_role" "bastion" {
  name = "kubernetes-${var.project_name}-bastion"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
      }
  ]
}
EOF
}


resource "aws_iam_role_policy" "bastion" {
  name = "kubernetes-${var.project_name}-bastion"
  role = "${aws_iam_role.bastion.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["*"],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": ["elasticloadbalancing:*"],
      "Resource": ["*"]
    }
  ]
}
EOF
}


resource "aws_iam_instance_profile" "bastion" {
  name = "kube_${var.project_name}_bastion_profile"
  role = "${aws_iam_role.bastion.name}"
}
