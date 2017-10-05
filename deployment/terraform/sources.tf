resource "aws_key_pair" "default" {
  public_key = "${file("${var.config_root_path}/${var.aws_cluster_name}/properties/ssh/rsakey.pub")}"
  key_name_prefix = "${var.aws_cluster_name}"
}


