# Day 3
리소스 Output 자원 활용
![output](https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2Fvniz4%2FbtrKn7Ud1nI%2Fr0PwlaT4VhPV5ve9mos1Kk%2Fimg.png)

## 백엔드 설정
### 사용하는 이유
- 협업 시에 리소스가 겹치거나 꼬이지 않게 `Locking` 하는 기능을 제공
- 로컬에 `.tfstate` 파일을 저장하여 관리하는 것보다 원격 저장소에 관리하는게 보안/관리적 측면에서 더 효과적임
- 생성된 리소스 자원(실제 상태)의 정보를 받아와 사용할 수 있음

## 코드로 보는 예제
- 기존 방식대로, 리소스를 개별 생성하고 `output`을 사용하지 않으면 생성된 리소스 자원을 하드 코딩하여 사용해야 함

### 기존 방식
```
resource "aws_instance" "example" {
  ami = data.aws_ami.amazon_linux_2.image_id
  instance_type = "t2.micro"

  availability_zone = "ap-northeast-2a"
  associate_public_ip_address = true

  subnet_id = "subnet-0ac6117143d6d85a7" # 하드 코딩되어 있는 Subnet ID
  vpc_security_group_ids = [ 
    "sg-08407e6e72976f46b"
  ]
}
```

### Output을 사용하여 생성된 리소스 자원을 가져오는 방식
```
# 백엔드에 있는 VPC 현재 상태에 대한 정보(.tfstate)를 받아옴
data "terraform_remote_state" "vpc" {
    backend = "s3"

    config = {
        bucket = "southouse-tfstate"
        key = "dev/services/vpc/terraform.tfstate"
        region = "${var.region}"
    }
}

locals {
  vpc_id = "${data.terraform_remote_state.vpc.outputs.vpc_id}"
  private_subnets = "${data.terraform_remote_state.vpc.outputs.private_subnets}"
  public_subnets = "${data.terraform_remote_state.vpc.outputs.public_subnets}"
}

resource "aws_instance" "example" {
  ami = data.aws_ami.amazon_linux_2.image_id
  instance_type = "t2.micro"

  availability_zone = "ap-northeast-2a"
  associate_public_ip_address = true

  subnet_id = "${local.public_subnets[0]}" # 원격 저장소에서 가져오는 현재 생성되어 있는 Subnet ID
  vpc_security_group_ids = [ 
    "sg-08407e6e72976f46b"
  ]
}
```