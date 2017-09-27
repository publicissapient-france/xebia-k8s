provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "default" {
  public_key = "${file("files/ssh/pubkey")}"
}


