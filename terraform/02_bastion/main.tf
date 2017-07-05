data "terraform_remote_state" "infra" {
  backend = "local"

  config {
    path = "${path.module}/../01_infra.tfstate"
  }
}

provider "aws" {
  region = "${var.region}"
}
