resource "aws_s3_bucket" "jasmin_bucket" {
  bucket_prefix = var.bucket_prefix
  versioning {
    enabled = true
  }

  tags = {
    Name = "jasmin-s3-bucket"
  }
}
