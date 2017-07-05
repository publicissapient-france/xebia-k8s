resource "aws_key_pair" "default" {
  public_key = "${file("ssh/rsakey.pub")}"
}
