# Day 2
VPC 프로비저닝
![vpc](https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdn%2FdamDGt%2FbtrJAB9VcKq%2FYkQmdk84ohkHtGQglPKESk%2Fimg.png)

## 모듈을 사용하는 이유
- 캡슐화
- 재사용성
- 일관성

## 코드로 보는 예제
- 모듈을 사용하지 않으면, 각각의 개별 리소스들을 하나씩 생성해주고, 의존성을 확인해줘야 함.
- 모듈을 사용하면 모듈 내 변수에 값만 할당해주면 알아서 리소스들을 생성해줌
### 모듈을 사용하지 않았을 때
```
resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/22"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public-2a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.0.0/26"

  tags = {
    Name = "public-2a"
  }
}

# resource "aws_subnet" "public-2b" {
#     ...
# }

# resource "aws_subnet" "public-2c" {
#     ...
# }

resource "aws_subnet" "private-2a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "192.168.1.0/26"

  tags = {
    Name = "Main"
  }
}

# resource "aws_subnet" "private-2b" {
#   ...
# }

# resource "aws_subnet" "private-2c" {
#   ...
# }

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway_attachment" "main" {
  internet_gateway_id = aws_internet_gateway.main.id
  vpc_id              = aws_vpc.main.id
}

# ... 나머지 리소스
```

### 모듈을 사용했을 때 (main.tf)
```
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.environment}-${var.common_prefix}"
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

  tags = "${local.common_tags}"

  igw_tags = "${merge(
    local.common_tags,
    tomap ({
      "Name" = "${var.common_prefix}-igw"
    })
  )}"

  database_subnet_group_tags = "${merge(
    local.common_tags,
    tomap ({
      "Name" = "${var.common_prefix}-private-db-subnet-group"
    })
  )}"
```
## 공식 지원 모듈과 비공식 지원 모듈
- 모듈은 직접 생성할 수 있음
- `Terraform Registry`에 존재하는 공식 지원 모듈도 사용 가능 (권장, 기능이 잘 갖춰져 있음)

## 코드 내용
### 가용성 확보
- 가용성을 유지하기 위해 서울 리전(`ap-northeast-2`)에 있는 가용 영역 4개 중 3개(`2a`, `2b`, `2c`)를 사용
- 추후에 인프라 구성 시 부하 분산(Scaling)이 가능함
### public, private, db 망 분리
- 클라이언트 단의 접근을 위한 `public` 망과, 내부 응용 프로그램들을 위한 `private` 망의 분리
- `public`망에는 `Load Balancer`가 위치
- `private`망에는 나머지 리소스들이 전부 위치
    - `web 서버`, `was 서버`, `배치 서버` 등
- `db`망에는 데이터와 관련된 리소스들이 위치
    - `database`, `redis` 등
### private, db 망 접근
- 개발/운영자의 접근을 위해서 private망 `route table`에 `nat gateway`를 생성
- 실습 시에는 요금 부담이 없게 하도록 `internet gateway`를 지정했음
- 이후 `bastion host`를 두어 private망에 접근