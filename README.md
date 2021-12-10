# Terraform state backend module
* terraform.tfstate 운영을 위한 S3 생성
* DynamoDB를 이용하여 terraform-state-locks 테이블 생성

## Usage

### `terraform.tfvars`
* 모든 변수는 적절하게 변경하여 사용
```
account_id = ["123456789012"] # 아이디 변경 필수, output 확인용, 실수 방지용도, 리소스에 사용하진 않음
region = "ap-northeast-2" # 리전 변경 필수, output 확인용, 실수 방지용도, 리소스에 사용하진 않음
s3_bucket = "bsg-terraform-state-backend"
s3_acl = "private"
dynamodb_table = "terraform-state-locks"

# 공통 tag, 생성되는 모든 리소스에 태깅
tags = {
    "CreatedByTerraform" = "true"
}
```
---

### `main.tf`
```
resource "aws_s3_bucket" "terraform_state_backend" {
  bucket = var.s3_bucket
  acl = var.s3_acl

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = merge(var.tags, tomap({Name = format("%s", var.s3_bucket)}))
}

resource "aws_dynamodb_table" "terraform_state_locks" {
  name = var.dynamodb_table
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(var.tags, tomap({Name = format("%s", var.dynamodb_table)}))
}
```
---

### `provider.tf`
```
provider  "aws" {
  region  =  var.region
}
```
---

### `terraform.tf`
```
terraform {
  required_version = ">= 0.15.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.39"
    }
  }
}
```
---

### `variables.tf`
```
variable "account_id" {
  description = "List of Allowed AWS account IDs"
  type = list(string)
  default = [""]
}

variable "region" {
  description = "AWS Region"
  type = string
  default = ""
}

variable "s3_bucket" {
  description = "S3 bucket for terraform-state-backend"
  type  = string
  default = ""
}

variable "s3_acl" {
  description = "ACL of S3 Bucket"
  type = string
  default = ""
}

variable "dynamodb_table" {
  description = "DynamoDB table for terraform-state-backend"
  type = string
  default = ""
}

variable "tags" {
  description = "tag map"
  type = map(string)
}
```
---

### `outputs.tf`
```
output "account_id" {
  description = "AWS Account ID"
  value = module.state-backend.account_id
}

output "region" {
  description = "region"
  value = module.state-backend.region
}

output "s3_bucket_name" {
  value = module.state-backend.s3_bucket_name
}

output "dynamodb_table_name" {
  value = module.state-backend.dynamodb_table_name
}
```