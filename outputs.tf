output "account_id" {
  description = "AWS Account ID"
  value = var.account_id
}

output "region" {
  description = "region"
  value = var.region
}

output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state_backend.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_state_locks.name
}