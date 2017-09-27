---
# Path where the kubespray ansible playbooks will be installed
# Defaults to current user's home directory if not set
# kubespray_path: "~/.kubespray"

# Default inventory path
kubespray_git_repo: "https://github.com/kubespray/kubespray.git"

# Logging options
loglevel: "info"

# The following options would be overwritten by the command line
# ---------------------------------------------------------
#
# Amazon web services options
# ---
# aws_access_key: "<key>"
# aws_secret_key: "<secret_key>"
# key_name: "<keypair_name>"
ami: "ami-674cbc1e"
masters_instance_type: "kube_xebia-k8s_master_profile"
nodes_instance_type: "kube_xebia-k8s_node_profile"
etcds_instance_type: "kube_xebia-k8s_etcd_profile"
# security_group_name: "<security_group_name>"
# security_group_id: "<security_group_id>"
# assign_public_ip: True
vpc_subnet_id: "subnet-2ce19c65"
region: "eu-west-1"
# tags:
#   - type: k8s
#
 Google Compute Engine options
# ---
# image: "<cloud_image>"
# masters_machine_type: "<masters_type>
# nodes_machine_type: "<masters_type>
# etcds_machine_type: "<masters_type>
# service_account_email: "<gce_service_account_email>"
# pem_file: "<gce_pem_file>"
# project_id: "<gce_project_id>"
# zone: "<cloud_region>"
# tags:
#   - k8s
#
# OpenStack options
# ---
# os_auth_url: "<os_auth_url>"
# os_username: "<os_username>"
# os_password: "<os_password>"
# os_project_name: "<os_project_name>"
# masters_flavor: "<os_flavor_name_or_id>"
# nodes_flavor: "<os_flavor_name_or_id>"
# etcds_flavor: "<os_flavor_name_or_id>"
# image: "<os_image_name_or_id>"
# network: "<os_network_name_or_id>"
# sshkey: "<os_ssh_key_name>"
#
# All the options to be passed to the 'ansible-playbook' command line
# ansible-opts:
#   - '-vvv'
#   - '-e'
#   - 'myvar1=bar'
#   - '-e'
#   - 'myvar2=foo'
