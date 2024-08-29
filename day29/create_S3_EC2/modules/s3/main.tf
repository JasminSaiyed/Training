resource "aws_s3_bucket" "app_bucket" {
  bucket = var.bucket_name

  tags = {
    Name = join("-", [var.bucket_name, "bucket"])
  }
}
