resource "aws_instance" "node" {
  count = "${var.node_count}"
  subnet_id = "${data.terraform_remote_state.infra.private_subnet}"
  ami = "${var.ami}"

  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.default.key_name}"
  source_dest_check = false
  root_block_device {
    volume_size = 40
  }
  iam_instance_profile = "${aws_iam_instance_profile.kube-worker.id}"

  # security group name here
  vpc_security_group_ids = [
    "${aws_security_group.allow_bastion.id}",
    "${aws_security_group.allow_elb.id}"
  ]

  tags {
    Name = "${var.project_name} - node${count.index + 1}"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
}


resource "aws_elb" "nodes" {
  subnets = [
    "${data.terraform_remote_state.infra.public_subnet}"
  ]
  name = "${var.project_name}-nodes"
  "listener" {
    instance_port = 80
    instance_protocol = "tcp"
    lb_port = 80
    lb_protocol = "tcp"
  }
  instances = [
    "${aws_instance.node.*.id}"
  ]

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:80"
    interval = 30
  }

  tags {
    Name = "${var.project_name} - nodes"
    Group = "${var.project_name}"
    Owner = "${var.owner}"
  }
  security_groups = [
    "${aws_security_group.allow_elb.id}"]
}

resource "aws_route53_record" "wildcard" {
  zone_id = "${data.aws_route53_zone.public_dns.id}"
  name = "*.${var.public_subdomain}.${var.public_domain}"
  type = "CNAME"
  ttl = "300"

  records = [
    "${aws_elb.nodes.dns_name}",
  ]
}
