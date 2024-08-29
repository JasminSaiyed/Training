terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}
module "ec2" {
  source        = "./modules/ec2/"
  ami_id        = "ami-000a81e3bab21747d"
  instance_type = var.instance_type
  region        = var.region
  instance_name = var.instance_name
}

module "s3" {
  source      = "./modules/s3/"
  bucket_name = var.bucket
}

