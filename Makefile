infra:
	@terraform apply -state terraform/01_infra.tfstate terraform/01_infra

bastion::
	@terraform apply -state terraform/02_bastion.tfstate terraform/02_bastion

cluster::
	@terraform apply -state terraform/03_cluster.tfstate terraform/03_cluster

cluster-destroy::
	@terraform destroy -state terraform/03_cluster.tfstate terraform/03_cluster

requirements:
	@ansible-galaxy install -r requirements.yml

destroy:
	@terraform destroy -force terraform

k8s::
	@ansible-playbook --flush-cache kubespray/cluster.yml

k8s-reset::
	@ansible-playbook kubespray/reset.yml