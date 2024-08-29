provider "aws" {
  region = "us-west-2" # Adjust the region as needed
}

module "aws_infrastructure" {
  source         = "./modules/aws_infrastructure"
  instance_type  = "t2.micro"
  ami_id          = "ami-0c55b159cbfafe1f0" # Example AMI ID
  key_name        = "my-key-pair"
  s3_bucket_name  = "my-unique-s3-bucket-name"
  private_key_path = "~/.ssh/id_rsa"
}

output "instance_public_ip" {
  value = module.aws_infrastructure.instance_public_ip
}

output "s3_bucket_arn" {
  value = module.aws_infrastructure.s3_bucket_arn
}
