terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.22.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
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

  subnet_id = "subnet-0cdfe9eb474e473ec"
  vpc_security_group_ids = [ 
    "sg-08407e6e72976f46b"
  ]

  key_name = "hello-aws"
  user_data_base64 = "IyEvYmluL2Jhc2gKbWtkaXIgL2hvbWUvZWMyLXVzZXIvZG93bmxvYWQKbWtkaXIgL2hvbWUvZWMyLXVzZXIvd29ya3NwYWNlCnRvdWNoIC9ob21lL2VjMi11c2VyL2V4YW1wbGUtZWMyICYmIGNobW9kICt4IC9ob21lL2VjMi11c2VyL2V4YW1wbGUtZWMyCgphbWF6b24tbGludXgtZXh0cmFzIGluc3RhbGwgbmdpbngxIC15CnJtIC91c3Ivc2hhcmUvbmdpbngvaHRtbC9pbmRleC5odG1sCmNhdCA8PCBFT0YgPiAvdXNyL3NoYXJlL25naW54L2h0bWwvaW5kZXguaHRtbAo8aHRtbD4KICAgIDxoZWFkPkhlbGxvLXRlcnJhZm9ybTwvaGVhZD4KICAgIDxib2R5PgogICAgICAgIDxoMj5IZWxsbywgVGVycmFmb3JtPC9oMj4KICAgIDwvYm9keT4KPC9odG1sPgpFT0YKc2VydmljZSBuZ2lueCBzdG9wCnNlcnZpY2Ugbmdpbnggc3RhcnQ="

  tags = {
    "Name" = "example",
    "Terraform" = true
  }
}

output "example_instance_id" {
  description = "Output example instance ID"
  value = aws_instance.example.id
}

output "example_instance_public_ip" {
  description = "Output example instance public IP"
  value = aws_instance.example.public_ip
}

output "example_instance_private_ip" {
  description = "Output example instance private IP"
  value = aws_instance.example.private_ip
}