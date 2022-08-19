provider "aws" {
  region = "${var.region}"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "<= 4.0"
    }
  }

  backend "s3" {
    bucket = "southouse-tfstate" # 변수 사용 불가능
    key = "global/s3/terraform.tfstate"
    region = "ap-northeast-2"
    encrypt = true
    dynamodb_table = "southouse-tfstate-lock"
  }
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "${var.common_prefix}-tfstate"

    tags = "${merge(
        local.common_tags,
        tomap ({
            "Name" = "${var.common_prefix}-tfstate"
        })
    )}"

    # depends_on = [
    #   terraform.backend.s3
    # ]
}

resource "aws_s3_bucket_acl" "terraform_state_acl" {
    bucket = aws_s3_bucket.terraform_state.id
    acl = "private"
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name = "${var.common_prefix}-tfstate-lock"
  hash_key = "LockID"
  read_capacity = 2
  write_capacity = 2

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = "${merge(
        local.common_tags,
        tomap ({
            "Name" = "${var.common_prefix}-tfstate-lock-table"
        })
    )}"
}