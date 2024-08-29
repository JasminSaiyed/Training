provider "aws" {
  region = "us-west-2"
  
}

resource "aws_s3_bucket" "jasmin_bucket" {
  bucket ="jasmin-bucket"
  versioning {
    enabled = true
  }

  tags = {
    Name = "jasmin-s3-bucket"

  }
}

resource "aws_dynamodb_table" "jasmin_terraform_lock" {
  name           = "jasmin_terraform_lock-table"
  read_capacity   = 5
  write_capacity  = 5
  hash_key        = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "jasmin-terraform-lock-table"
  }
}
