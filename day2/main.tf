terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.22.0"
    }
  }
}

provider "aws" {
  region = "${var.region}"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.common_prefix}"
  cidr = "192.168.0.0/22"

  azs = ["ap-northeast-2a", "ap-northeast-2b", "ap-northeast-2c"]

  public_subnets = ["192.168.0.0/26", "192.168.0.64/26", "192.168.0.128/26"]
  public_subnet_suffix = "public"
  
  private_subnets = ["192.168.1.0/26", "192.168.1.64/26", "192.168.1.128/26"]
  private_subnet_suffix = "private"

  database_subnets = ["192.168.2.0/26", "192.168.2.64/26", "192.168.2.128/26"]
  database_subnet_group_name = "${var.common_prefix}-private-db-subnet-group"
  database_subnet_suffix = "private-db"

  enable_nat_gateway = false
  # single_nat_gateway = true

  tags = {
    "Environment" = "${var.environment}",
    "Terraform" = true
  }

  igw_tags = {
    "Name" = "${var.common_prefix}-igw",
    "Environment" = "${var.environment}",
    "Terraform" = true
  }

  database_subnet_group_tags = {
    "Name" = "${var.common_prefix}-private-db-subnet-group",
    "Environment" = "${var.environment}",
    "Terraform" = true
  }

}