variable "project_name" {}

variable "owner" {}

variable "ami" {}

variable "region" {}

variable "instance_type" {}

variable "public_domain" {}

variable "public_subdomain" {}

variable "node_count" {}

variable "bastion_ip" {
  default = "10.0.90.208"
}
