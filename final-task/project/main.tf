provider "aws" {
  region = "ap-northeast-1"
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

module "network" {
  source = "./modules/network"
}

module "compute" {
  source    = "./modules/compute"
  ami_id    = "ami-0cab37bd176bb80d3"
  subnet_id = module.network.subnet_id
  vpc_id    = module.network.vpc_id
}

module "storage" {
  source      = "./modules/storage"
  bucket_name = "unique-bucket-name-123456"
}
