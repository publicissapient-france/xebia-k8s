output "ceph" {
  value = ["${aws_instance.ceph.*.private_ip}"]
}
