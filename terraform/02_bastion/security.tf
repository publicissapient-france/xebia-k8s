resource "aws_security_group" "ssh" {
  vpc_id      = "${data.terraform_remote_state.infra.vpc_id}"
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
