provider "aws" {
  region = "${var.region}"
}

resource "aws_instance" "ceph" {
  count = "3"
  subnet_id = "${data.terraform_remote_state.infra.private_subnet}"
  ami = "${var.ami}"

  instance_type = "${var.instance_type}"
  key_name = "${data.terraform_remote_state.bastion.key_name}"

  # security group name here
  vpc_security_group_ids = [
    "${aws_security_group.ceph.id}",
  ]

  root_block_device {
    volume_size = 40
  }

  provisioner "remote-exec" {
    inline = "sleep 1"

    connection {
      user = "ubuntu"
      private_key = "${file("ssh/rsakey")}"
      bastion_host = "${data.terraform_remote_state.bastion.bastion_addr}"
    }
  }

  tags {
    Name = "${var.project_name} - ceph ${count.index + 1}"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}


#Ceph Security Groups

resource "aws_security_group" "ceph" {
  name = "${var.project_name}-ceph-sg"
  vpc_id = "${data.terraform_remote_state.infra.vpc_id}"

  tags {
    Name = "${var.project_name} - ceph sg"
  }
}

resource "aws_security_group_rule" "allow-all-ingress" {
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [
    "${data.terraform_remote_state.infra.private_cidr_block}"]
  security_group_id = "${aws_security_group.ceph.id}"
}

resource "aws_security_group_rule" "allow-all-egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [
    "0.0.0.0/0"]
  security_group_id = "${aws_security_group.ceph.id}"
}


resource "aws_security_group_rule" "allow-ssh-connections" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "TCP"
  cidr_blocks = [
    "0.0.0.0/0"]
  security_group_id = "${aws_security_group.ceph.id}"
}
