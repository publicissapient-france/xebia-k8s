terraform {
  required_version = ">= 0.8.7"
}

provider "aws" {
  access_key = "${var.AWS_ACCESS_KEY_ID}"
  secret_key = "${var.AWS_SECRET_ACCESS_KEY}"
  region = "${var.AWS_DEFAULT_REGION}"
}

/*
* Calling modules who create the initial AWS VPC / AWS ELB
* and AWS IAM Roles for Kubernetes Deployment
*/

module "aws-vpc" {
  source = "modules/vpc"

  aws_cluster_name = "${var.aws_cluster_name}"
  aws_vpc_cidr_block = "${var.aws_vpc_cidr_block}"
  aws_avail_zones = "${var.aws_avail_zones}"

  aws_cidr_subnets_private = "${var.aws_cidr_subnets_private}"
  aws_cidr_subnets_public = "${var.aws_cidr_subnets_public}"

}


module "aws-elb" {
  source = "modules/elb"

  aws_cluster_name = "${var.aws_cluster_name}"
  aws_vpc_id = "${module.aws-vpc.aws_vpc_id}"
  aws_avail_zones = "${var.aws_avail_zones}"
  aws_subnet_ids_public = "${module.aws-vpc.aws_subnet_ids_public}"
  aws_elb_api_port = "${var.aws_elb_api_port}"
  k8s_secure_api_port = "${var.k8s_secure_api_port}"
  public_domain_zone_id = "${data.aws_route53_zone.public_dns.zone_id}"
}

module "aws-iam" {
  source = "modules/iam"

  aws_cluster_name = "${var.aws_cluster_name}"
}

/*
* Create Bastion Instances in AWS
*
*/
resource "aws_instance" "bastion-server" {
  ami = "${var.aws_bastion_ami}"
  instance_type = "${var.aws_bastion_size}"
  count = "${length(var.aws_cidr_subnets_public)}"
  associate_public_ip_address = true
  availability_zone = "${element(var.aws_avail_zones,count.index)}"
  subnet_id = "${element(module.aws-vpc.aws_subnet_ids_public,count.index)}"

  provisioner "remote-exec" {
    inline = "sleep 1"

    connection {
      user = "ubuntu"
      private_key = "${file("${var.config_root_path}/${var.aws_cluster_name}/ssh/rsakey.pub")}"
    }
  }

  vpc_security_group_ids = [
    "${module.aws-vpc.aws_security_group}"]

  key_name = "${aws_key_pair.default.key_name}"

  tags {
    Name = "kubernetes-${var.aws_cluster_name}-bastion-${count.index}"
    Cluster = "${var.aws_cluster_name}"
    Role = "bastion-${var.aws_cluster_name}-${count.index}"
  }
}

resource "aws_route53_record" "bastion-server" {
  name = "bastion.${var.aws_cluster_name}"
  records = [
    "${aws_instance.bastion-server.*.public_ip}"
  ]
  type = "A"
  ttl = "60"
  zone_id = "${data.aws_route53_zone.public_dns.zone_id}"
}

/*
* Create K8s Master and worker nodes and etcd instances
*
*/

resource "aws_instance" "k8s-master" {
  ami = "${var.aws_cluster_ami}"
  instance_type = "${var.aws_kube_master_size}"

  count = "${var.aws_kube_master_num}"

  availability_zone = "${element(var.aws_avail_zones,count.index)}"
  subnet_id = "${element(module.aws-vpc.aws_subnet_ids_private,count.index)}"

  vpc_security_group_ids = [
    "${module.aws-vpc.aws_security_group}"
  ]


  iam_instance_profile = "${module.aws-iam.kube-master-profile}"
  key_name = "${aws_key_pair.default.key_name}"

  provisioner "remote-exec" {
    inline = "sleep 1"

    connection {
      user = "ubuntu"
      private_key = "${file("${var.config_root_path}/${var.aws_cluster_name}/ssh/rsakey.pub")}"
      bastion_host = "${aws_instance.bastion-server.public_dns}"
    }
  }

  tags {
    Name = "kubernetes-${var.aws_cluster_name}-master${count.index}"
    Cluster = "${var.aws_cluster_name}"
    Role = "master"
  }
}

resource "aws_elb_attachment" "attach_master_nodes" {
  count = "${var.aws_kube_master_num}"
  elb = "${module.aws-elb.aws_elb_api_id}"
  instance = "${element(aws_instance.k8s-master.*.id,count.index)}"
}


resource "aws_instance" "k8s-etcd" {
  ami = "${var.aws_cluster_ami}"
  instance_type = "${var.aws_etcd_size}"

  count = "${var.aws_etcd_num}"

  availability_zone = "${element(var.aws_avail_zones,count.index)}"
  subnet_id = "${element(module.aws-vpc.aws_subnet_ids_private,count.index)}"

  vpc_security_group_ids = [
    "${module.aws-vpc.aws_security_group}"]

  key_name = "${aws_key_pair.default.key_name}"

  provisioner "remote-exec" {
    inline = "sleep 1"

    connection {
      user = "ubuntu"
      private_key = "${file("${var.config_root_path}/${var.aws_cluster_name}/ssh/rsakey.pub")}"
      bastion_host = "${aws_instance.bastion-server.public_dns}"
    }
  }

  tags {
    Name = "kubernetes-${var.aws_cluster_name}-etcd${count.index}"
    Cluster = "${var.aws_cluster_name}"
    Role = "etcd"
  }

}


resource "aws_instance" "k8s-worker" {
  ami = "${var.aws_cluster_ami}"
  instance_type = "${var.aws_kube_worker_size}"

  count = "${var.aws_kube_worker_num}"

  availability_zone = "${element(var.aws_avail_zones,count.index)}"
  subnet_id = "${element(module.aws-vpc.aws_subnet_ids_private,count.index)}"

  vpc_security_group_ids = [
    "${module.aws-vpc.aws_security_group}"]

  iam_instance_profile = "${module.aws-iam.kube-worker-profile}"
  key_name = "${aws_key_pair.default.key_name}"

  provisioner "remote-exec" {
    inline = "sleep 1"

    connection {
      user = "ubuntu"
      private_key = "${file("${var.config_root_path}/${var.aws_cluster_name}/ssh/rsakey.pub")}"
      bastion_host = "${aws_instance.bastion-server.public_dns}"
    }
  }

  tags {
    Name = "kubernetes-${var.aws_cluster_name}-worker${count.index}"
    Cluster = "${var.aws_cluster_name}"
    Role = "worker"
  }

}


/*
* Create Kubespray Inventory File
*
*/
data "template_file" "inventory" {
  template = "${file("${path.module}/templates/inventory.tpl")}"

  vars {
    public_ip_address_bastion = "${join("\n",formatlist("bastion ansible_ssh_host=%s" , aws_instance.bastion-server.*.public_ip))}"
    connection_strings_master = "${join("\n",formatlist("%s ansible_ssh_host=%s",aws_instance.k8s-master.*.tags.Name, aws_instance.k8s-master.*.private_ip))}"
    connection_strings_node = "${join("\n", formatlist("%s ansible_ssh_host=%s", aws_instance.k8s-worker.*.tags.Name, aws_instance.k8s-worker.*.private_ip))}"
    connection_strings_etcd = "${join("\n",formatlist("%s ansible_ssh_host=%s", aws_instance.k8s-etcd.*.tags.Name, aws_instance.k8s-etcd.*.private_ip))}"
    list_master = "${join("\n",aws_instance.k8s-master.*.tags.Name)}"
    list_node = "${join("\n",aws_instance.k8s-worker.*.tags.Name)}"
    list_etcd = "${join("\n",aws_instance.k8s-etcd.*.tags.Name)}"
    elb_api_fqdn = "apiserver_loadbalancer_domain_name=\"${module.aws-elb.aws_elb_api_fqdn}\""
    elb_api_port = "loadbalancer_apiserver.port=${var.aws_elb_api_port}"
    loadbalancer_apiserver_address = "loadbalancer_apiserver.address=${module.aws-elb.aws_elb_api_fqdn}"
  }

}

resource "null_resource" "inventories" {
  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' > ${var.config_root_path}/${var.aws_cluster_name}/inventory/hosts"
  }

  triggers {
    template = "${data.template_file.inventory.rendered}"
  }

}
