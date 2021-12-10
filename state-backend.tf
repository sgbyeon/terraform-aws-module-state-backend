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