variable "region" {
    description = "service in ap-northeast-2 region"
    default = "ap-northeast-2"
}

variable "example" {
  description = "Hello Variable"
  default = "this is exmaple."
}

variable "common_prefix" {
  default = "southouse"
}

variable "environment" {
  default = "all"
}

locals {
  common_tags = tomap(
    {
      "Terraform" = true, 
      "Environment" = "${var.environment}"
    }
  )
}