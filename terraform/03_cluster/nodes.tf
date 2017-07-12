resource "aws_instance" "node" {
  count     = "3"
  subnet_id = "${data.terraform_remote_state.infra.private_subnet}"
  ami       = "${var.ami}"

  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.default.key_name}"

  root_block_device {
    volume_size = 40
  }


  # security group name here
  vpc_security_group_ids = [
    "${aws_security_group.allow_bastion.id}",
  ]

  provisioner "remote-exec" {
    inline = "sleep 1"

    connection {
      user         = "ubuntu"
      private_key  = "${file("ssh/rsakey")}"
      bastion_host = "${data.terraform_remote_state.bastion.bastion_addr}"
    }
  }

  tags {
    Name  = "${var.project_name} - node${count.index + 1}"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}
