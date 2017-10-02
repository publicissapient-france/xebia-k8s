variable "project_name" {}

variable "owner" {}

variable "ami" {}

variable "region" {}

variable "instance_type" {
  default = "t2.nano"
}

variable cidr_block {
  type    = "string"
  default = "10.0.0.0/16"
}

variable subnet_block_size {
  default = 8
}

variable "public_domain" {}
variable "public_subdomain" {}

# Tools versions
variable "terraform_version" {}
variable "ansible_version" {}
variable "kubectl_version" {}
variable "kubespray_version" {}
