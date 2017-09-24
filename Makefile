infra:
	@terraform apply -state terraform/01_infra.tfstate terraform/01_infra

bastion::
	@terraform apply -state terraform/02_bastion.tfstate terraform/02_bastion

cluster::
	@terraform apply -state terraform/03_cluster.tfstate terraform/03_cluster


cluster-destroy::
	@terraform destroy -state terraform/03_cluster.tfstate terraform/03_cluster

ceph::
	@terraform apply -state terraform/04_ceph.tfstate terraform/04_ceph

init:
#	@terraform init terraform/03_cluster
	@terraform init terraform/01_infra


destroy:
	@terraform destroy -state terraform/03_cluster.tfstate -force terraform/03_cluster
	@terraform destroy -force -state terraform/02_bastion.tfstate terraform/02_bastion
	@terraform destroy -state terraform/01_infra.tfstate -force terraform/01_infra

k8s::
	@ansible-playbook --flush-cache kubespray/cluster.yml

k8s-reset::
	@ansible-playbook kubespray/reset.yml

ssh::
	ssh -F ssh_config bastion
