gateway:
	@ansible-playbook ansible/gateway.yml
	@curl --retry 10 --retry-delay 3 -k https://vpn.k8s.techx.fr:8080 > xebia-k8s.ovpn

infra:
	@terraform apply -state terraform/01_infra.tfstate terraform/01_infra

bastion::
	@terraform apply -state terraform/02_bastion.tfstate terraform/02_bastion

cluster::
	@terraform apply -state terraform/03_cluster.tfstate terraform/03_cluster

requirements:
	@ansible-galaxy install -r requirements.yml

destroy:
	@terraform destroy -force terraform
