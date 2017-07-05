variable "project_name" {}

variable "owner" {}

variable "ami" {}

variable "region" {}

variable "instance_type" {}

variable "public_domain" {}

variable "public_subdomain" {}

variable cidr_block {
  type    = "string"
  default = "10.0.0.0/16"
}

variable subnet_block_size {
  default = 8
}
