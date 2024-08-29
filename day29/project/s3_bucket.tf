resource "aws_s3_bucket" "terraform_state" {
  bucket = "jasmin-terraform-state-bucket"

  tags = {
    Name = "jasmin Terraform State Bucket"
  }
}
