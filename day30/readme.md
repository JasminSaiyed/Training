+ Project: Advanced Terraform with Provisioners, Modules, and Workspaces
Project Objective:
This project is designed to evaluate participants' understanding of Terraform provisioners, modules, and workspaces. The project involves deploying a basic infrastructure on AWS using Terraform modules, executing remote commands on the provisioned resources using provisioners, and managing multiple environments using Terraform workspaces. All resources should be within the AWS Free Tier limits.
Project Overview:
Participants will create a Terraform configuration that deploys an EC2 instance and an S3 bucket using a custom Terraform module. The project will also require the use of Terraform provisioners to execute scripts on the EC2 instance. Finally, participants will manage separate environments (e.g., dev and prod) using Terraform workspaces.
Specifications:
+ Terraform Modules:
Create a reusable module to deploy an EC2 instance and an S3 bucket.
The EC2 instance should be of type t2.micro, and the S3 bucket should be configured for standard storage.
The module should accept input variables for the instance type, AMI ID, key pair name, and bucket name.
Outputs should include the EC2 instance’s public IP and S3 bucket’s ARN.
+ create modules for s3
create main.tf
resource "aws_s3_bucket" "jasmin_bucket" {
  bucket_prefix = var.bucket_prefix
  versioning {
    enabled = true
  }

  tags = {
    Name = "jasmin-s3-bucket"
  }
}
create outputs.tf
output "bucket_name" {
  value = aws_s3_bucket.jasmin_bucket.bucket
}
create variables.tf
variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
}
+ create modules for ec2
create main.tf
resource "aws_instance" "jasmin_app" {
  count                    = var.instance_count
  ami                      = var.ami_id
  instance_type            = var.instance_type
  subnet_id                = element(var.public_subnet_ids, count.index)
  key_name                 = var.key_name
  associate_public_ip_address = true
  security_groups          = [var.security_group_id]

  tags = {
    Name = "jasmin-app-instance-${count.index}"
  }
}
create outputs.tf
output "instance_ids" {
  value = aws_instance.jasmin_app[*].id
}
create variables.tf
variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default    = "jasmin"
}

variable "security_group_id" {
  description = "Security Group ID for EC2 instances"
  type        = string
}
Terraform Provisioners:
Use remote-exec and local-exec provisioners to perform post-deployment actions on the EC2 instance.
+ The remote-exec provisioner should be used to connect to the EC2 instance via SSH and run a script that installs Apache HTTP Server.
The local-exec provisioner should be used to output a message on the local machine indicating the deployment status, such as "EC2 instance successfully provisioned with Apache."
Terraform Workspaces:
Implement Terraform workspaces to manage separate environments (e.g., dev and prod).
Each workspace should deploy the same infrastructure (EC2 and S3) but with different configurations (e.g., different tags or bucket names).
Ensure that the state for each workspace is managed separately to prevent conflicts between environments.
remote-exec
provisioner "remote-exec" {
  inline = [
  "sudo apt-get update -y",
  "sudo apt-get install -y apache2",
  "sudo systemctl start apache2",
  "sudo systemctl enable apache2"
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }
}
local-exec
provisioner "local-exec" {
  command = "echo 'EC2 instance successfully provisioned with Apache.'"
}
Variable Inputs: Define input variables for instance type, AMI ID, key pair name, and S3 bucket name.variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  default     = ["us-west-2a", "us-west-2b"]
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  default     = "ami-05134c8ef96964280"
}

variable "db_username" {
  description = "Database username"
}

variable "db_password" {
  description = "Database password"
  sensitive   = true
}

variable "s3_bucket_prefix" {
  description = "Prefix for the S3 bucket name"
}

variable "aws_profile" {
  type        = string
  description = "The AWS CLI profile to use for this workspace"
}


Outputs: Define outputs for the EC2 instance's public IP and the S3 bucket's ARN.
Main Terraform Configuration:
Main Config Setup: In the root directory, create a Terraform configuration that calls the custom module.
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
Backend Configuration: Configure Terraform to use local state storage for simplicity (optional for Free Tier compliance).
terraform {
  backend "local" {}
}
![img-1](<Screenshot from 2024-08-29 12-54-57.png>)
![img-2](<Screenshot from 2024-08-29 12-58-34.png>)
![img-3](<Screenshot from 2024-08-29 13-00-14.png>)
![img-4](<Screenshot from 2024-08-29 12-52-45.png>)
Resource Cleanup:
Destroy Resources: Use terraform destroy to remove the resources in both workspaces.
Workspace Management: Confirm that the resources are destroyed separately in each workspace and that the state files are updated accordingly.
Documentation:
Module Documentation: Provide detailed documentation of the Terraform module, including variable definitions, provisioners, and outputs.
Workspace Documentation: Document the process for creating and managing Terraform workspaces.
Provisioner Documentation: Include descriptions of the provisioners used and their purpose.

