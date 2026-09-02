module "security-group-module" {
    source = "./security-group"
    vpc_id = aws_vpc.vpc.id
}

variable "ec2_name"{
    type = string
    default = "web-server-dev"
}

resource "aws_vpc" "vpc"{
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "terraform-aws-oidc-pipeline-vpc"
    }
}

resource "aws_internet_gateway" "igw"{
    vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "public_subnet"{
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
}

resource "aws_route_table" "public_rt"{
    vpc_id = aws_vpc.vpc.id

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "public_rta"{
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_instance" "web_server" {
    ami = "ami-07b8fb6bd3e9627a6"
    instance_type = "t3.micro"
    subnet_id = aws_subnet.public_subnet.id
    vpc_security_group_ids = [module.security-group-module.sg_output]

    user_data = file("server-script.sh")
    tags = {
        Name = var.ec2_name 
    }
}