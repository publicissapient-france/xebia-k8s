resource "aws_key_pair" "default" {
  public_key = "${file("${var.config_root_path}/${var.aws_cluster_name}/properties/ssh/rsakey.pub")}"
  key_name_prefix = "${var.aws_cluster_name}"
}

terraform {
  backend "s3" {
    bucket = "${var.s3_bucket}"
    key    = "${var.aws_cluster_name}"
    region = "${var.AWS_DEFAULT_REGION}"
  }
}
