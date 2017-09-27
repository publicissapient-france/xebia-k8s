# Global Vars
aws_cluster_name = "xebia-k8s-prod"

AWS_ACCESS_KEY_ID = ""
AWS_SECRET_ACCESS_KEY = ""
AWS_SSH_KEY_NAME = ""
AWS_DEFAULT_REGION = "eu-west-1"

# VPC Vars
aws_vpc_cidr_block = "10.250.192.0/18"
aws_cidr_subnets_private = ["10.250.192.0/20","10.250.208.0/20"]
aws_cidr_subnets_public = ["10.250.224.0/20","10.250.240.0/20"]
aws_avail_zones = ["eu-west-1a","eu-west-1b"]

# Bastion Host
aws_bastion_ami = "ami-674cbc1e"
aws_bastion_size = "t2.small"


# Kubernetes Cluster
aws_kube_master_num = 3
aws_kube_master_size = "t2.medium"

aws_etcd_num = 3
aws_etcd_size = "t2.medium"

aws_kube_worker_num = 4
aws_kube_worker_size = "t2.medium"

aws_cluster_ami = "ami-674cbc1e"

# Settings AWS ELB
aws_elb_api_port = 443
k8s_secure_api_port = 443
kube_insecure_apiserver_address = "127.0.0.1"
