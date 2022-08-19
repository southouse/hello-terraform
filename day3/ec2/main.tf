terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.22.0"
    }
  }

#   backend "s3" {
#     bucket = "southouse-tfstate"
#     key = "dev/services/ec2/terraform.tfstate"
#     region = "ap-northeast-2"
#     encrypt = true
#     dynamodb_table = "southouse-tfstate-lock"
#   }
}

provider "aws" {
  region = "${var.region}"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-*"]
  }
}

resource "aws_instance" "example" {
  ami = data.aws_ami.amazon_linux_2.image_id
  instance_type = "t2.micro"

  availability_zone = "ap-northeast-2a"
  associate_public_ip_address = true

  subnet_id = "${local.public_subnets[0]}"
  vpc_security_group_ids = [ 
    "sg-08407e6e72976f46b"
  ]

  key_name = "${local.key_name}"
  user_data_base64 = "${local.user_data_base64}"

  tags = {
    "Name" = "example",
    "Terraform" = true
  }
}
