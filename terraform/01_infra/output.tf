output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

output "region" {
  value = "${var.region}"
}

output "public_subnet" {
  value = "${aws_subnet.public.id}"
}

output "masters_instance_profile_name" {
  value = "${aws_iam_instance_profile.kube-master.name}"
}

output "nodes_instance_profile_name" {
  value = "${aws_iam_instance_profile.kube-worker.name}"
}

output "etcd_instance_profile_name" {
  value = "${aws_iam_instance_profile.kube-etcd.name}"
}


output "k8s_subnet_prod" {
  value = "${aws_subnet.private.id}"
}
