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
  default = "dev"
}

# data "terraform_remote_state" "vpc" {
#     backend = "s3"

#     config = {
#         bucket = "southouse-tfstate"
#         key = "dev/services/vpc/terraform.tfstate"
#         region = "${var.region}"
#     }
# }

locals {
  common_tags = tomap(
    {
      "Terraform" = true, 
      "Environment" = "${var.environment}"
    }
  )

  key_name = "hello-aws"
  user_data_base64 = "IyEvYmluL2Jhc2gKbWtkaXIgL2hvbWUvZWMyLXVzZXIvZG93bmxvYWQKbWtkaXIgL2hvbWUvZWMyLXVzZXIvd29ya3NwYWNlCnRvdWNoIC9ob21lL2VjMi11c2VyL2V4YW1wbGUtZWMyICYmIGNobW9kICt4IC9ob21lL2VjMi11c2VyL2V4YW1wbGUtZWMyCgphbWF6b24tbGludXgtZXh0cmFzIGluc3RhbGwgbmdpbngxIC15CnJtIC91c3Ivc2hhcmUvbmdpbngvaHRtbC9pbmRleC5odG1sCmNhdCA8PCBFT0YgPiAvdXNyL3NoYXJlL25naW54L2h0bWwvaW5kZXguaHRtbAo8aHRtbD4KICAgIDxoZWFkPkhlbGxvLXRlcnJhZm9ybTwvaGVhZD4KICAgIDxib2R5PgogICAgICAgIDxoMj5IZWxsbywgVGVycmFmb3JtPC9oMj4KICAgIDwvYm9keT4KPC9odG1sPgpFT0YKc2VydmljZSBuZ2lueCBzdG9wCnNlcnZpY2Ugbmdpbnggc3RhcnQ="

  # vpc_id = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
  # private_subnets = "${data.terraform_remote_state.vpc.outputs.private_subnets}"
  # public_subnets = "${data.terraform_remote_state.vpc.outputs.public_subnets}"
}