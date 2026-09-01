provider "aws" {
    region = "eu-north-1"
}

module "web-module" {
    source = "./web"
    ec2_name = "Web server"
}