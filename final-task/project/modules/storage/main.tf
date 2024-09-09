resource "aws_s3_bucket" "this" {
  bucket = "unique-bucket-name-123456" # Replace with a new unique name
  acl    = "private"

  tags = {
    Name = "task1-jasmin"
  }
}


output "bucket_id" {
  value = aws_s3_bucket.this.id
}

