resource "aws_security_group" "allow_bastion" {
  vpc_id = "${data.terraform_remote_state.infra.vpc_id}"
  name_prefix = "${var.project_name}-sg"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"

    security_groups = [
      "${data.terraform_remote_state.bastion.bastion_sg}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags {
    Name = "${var.project_name} - allow bastion"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}
