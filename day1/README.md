# Day 1
EC2 프로비저닝

## 환경 구성
- IAM 그룹 및 권한 생성
- 액세스 키 발급, `aws-cli` 를 통해 등록

## 테라폼 문법
### 리소스 선언
 - `<block type> “<resource type>” “<local name/label>”`
 ```
<block_type> "<resource_type>" "<local_name/label>" {
   ami           = "ami-123456"
   instance_type = "t2.micro"
}

resource "aws_instance" "db" {
   ami           = "ami-123456"
   instance_type = "t2.micro"
}
 ```
 - `"<local_name/label>"`은 소스 내에서 참조를 위해 사용하는 변수
### Output
 - 프로비저닝 된 리소스의 메타데이터를 가져옴

## 코드 내용
### 암시적(Implicit), 명시적(explicit) 종속성
- 암시적 종속성 (Implicit Dependency)
 EC2 인스턴스가 생성된 이후에 EIP가 생성되어 연결 됨
 ```
resource "aws_instance" "example_a" {
   ami           = data.aws_ami.amazon_linux.id
   instance_type = "t2.micro"
}

resource "aws_eip" "ip" {
   vpc = true
   instance = aws_instance.example_a.id
}
 ```
- 명시적 종속성 (Explicit Dependency)
 S3 버킷이 생성된 후에 EC2 인스턴스가 생성 됨 (depends_on 리소스를 먼저 생성 후에 현재 리소스 생성)
 ```
    resource "aws_instance" "example" {
    ami           = "ami-2757f631"
    instance_type = "t2.micro"
    depends_on = [aws_s3_bucket.company_data]
    }
 ```
### terraform.tfstate
 - 현재 리소스의 상태를 저장
 - 소스 관리 시에 `.tfstate` 파일은 ignore 혹은 원격으로 관리

## 커맨드
- `terraform init`
   - 테라폼 프로젝트 디렉토리를 초기화
- `terraform plan`
   - 현재 코드로 작성된 리소스와 실제 리소스를 비교
   - 이상적인 상태(Desired State)에 존재하는 상태
- `terraform apply`
   - 현재 코드로 작성된 리소스와 실제 리소스를 비교하고, 적용
   - 적용하면 이상적인 상태와 실제 상태(current state)가 동일해짐
- `terraform destroy`   
   - 리소스를 삭제
   - `-target={REF_NAME}` 이라는 파라미터를 통해 원하는 리소스를 삭제 가능

## Reference
- https://www.44bits.io/ko/post/terraform_introduction_infrastrucute_as_code