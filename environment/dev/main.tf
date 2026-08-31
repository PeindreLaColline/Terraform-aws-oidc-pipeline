provider "aws" {
    region = "eu-north-1"
    profile = "dev-profile"
}

module "web-module" {
    source = "./web"
    ec2_name = "Web server"
}