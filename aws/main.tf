variable "ec2_name" {
  type = string
}

provider "aws" {
  region = "eu-north-1"
}

module "web-module" {
  source   = "./web"
  ec2_name = var.ec2_name
}