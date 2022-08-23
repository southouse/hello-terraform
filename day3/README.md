# Day 3
백엔드 설정 및 리소스 작업 디렉토리 분리
![output](https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2Fvniz4%2FbtrKn7Ud1nI%2Fr0PwlaT4VhPV5ve9mos1Kk%2Fimg.png)

## Terraform Backend

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

# 원격 저장소에서 가져오는 현재 생성되어 있는 Subnet ID
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

  subnet_id = "${local.public_subnets[0]}" 
  vpc_security_group_ids = [ 
    "sg-08407e6e72976f46b"
  ]
}
```

## 코드 내용

### 리소스 별로 작업 디렉토리 분리
- 가독성을 위해 사용하는 리소스에 따라 디렉토리를 분리
- 외부 작업 디렉토리에서 리소스를 참조하기 위해 필요한 `output`을 정의

### local과 variable의 차이

#### variable
- `default`로 기본 값을 설정할 수 있음
- `description`으로 설명을 포함할 수 있음
- 명령어 인자나 파일로 사용자의 입력을 받을 수 있음

#### local
- 현재 실행 파일에서 사용되는 지역 변수의 개념
- `terraform` 함수와 같이 사용할 수 있음

### 백엔드 설정
- s3, consul 등 다양한 백엔드 타입을 지정할 수 있음
- 설정 후 `terraform init` 명령이 선행되어야 함
- 각 리소스의 `.tfstate` 파일이 저장될 경로를 지정
- 원격 백엔드에 지정된 데이터를 불러올 땐 `data` 스코프를 사용