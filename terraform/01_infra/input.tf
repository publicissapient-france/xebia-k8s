variable "project_name" {}

variable "owner" {}

variable "bastion_ami" {}

variable "region" {}

variable "instance_type" {}

variable "public_domain" {}

variable "public_subdomain" {}

variable "vpn_psk"{}
variable "vpn_password"{}
variable "vpn_user"{}

variable cidr_block {
  type    = "string"
  default = "10.0.0.0/16"
}

variable subnet_block_size {
  default = 8
}
