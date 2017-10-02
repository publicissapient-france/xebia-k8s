#Global Vars
aws_cluster_name = "k8s-testing"

# Environmemnt settings
config_root_path = "/tmp/"
public_domain = "techx.fr"

#VPC Vars
aws_vpc_cidr_block = "10.250.192.0/18"
aws_cidr_subnets_private = ["10.250.192.0/20","10.250.208.0/20"]
aws_cidr_subnets_public = ["10.250.224.0/20","10.250.240.0/20"]
aws_avail_zones = ["eu-west-1a","eu-west-1b"]

#Bastion Host
aws_bastion_ami = "ami-17d11e6e"
aws_bastion_size = "t2.nano"

#Kubernetes Cluster
aws_kube_master_num = 3
aws_kube_master_size = "t2.medium"

aws_etcd_num = 3
aws_etcd_size = "t2.medium"

aws_kube_worker_num = 2
aws_kube_worker_size = "t2.medium"

aws_cluster_ami = "ami-17d11e6e"

#Settings AWS ELB
aws_elb_api_port = 6443
k8s_secure_api_port = 6443
kube_insecure_apiserver_address = "127.0.0.1"
loadbalancer_apiserver_address = ""