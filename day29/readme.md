+ Project: Advanced Terraform with Modules, Functions, State Locks, Remote State Management, and Variable Configuration
+ Project Objective:
This project will test your skills in using Terraform modules, functions, variables, state locks, and remote state management. The project requires deploying infrastructure on AWS using a custom Terraform module and managing the state remotely in an S3 bucket, while testing the locking mechanism with DynamoDB. Participants will also configure variables and outputs using functions.
+ Project Overview:
You will create a Terraform configuration that uses a custom module to deploy a multi-component infrastructure on AWS. The state files will be stored remotely in an S3 bucket, and DynamoDB will handle state locking. Additionally, the project will involve creating a flexible and reusable Terraform module, using input variables (tfvars) and Terraform functions to parameterize configurations.
Specifications:
Terraform Modules: Create a reusable module that can deploy both an EC2 instance and an S3 bucket.
Terraform Functions: Use Terraform built-in functions to manipulate and compute variable values (e.g., length, join, lookup).
State Management: Store the Terraform state in an S3 bucket and configure DynamoDB for state locking to prevent concurrent changes.
Variable Configuration (tfvars): Parameterize the infrastructure using variables for instance type, region, and other configurable options.
Outputs: Use outputs to display important information such as EC2 instance details and the S3 bucket name after deployment.
+ Key Tasks:
- Remote State Management:
S3 Bucket for State:
Create an S3 bucket using Terraform (this can be separate from the custom module).
Configure Terraform to store the state file in the S3 bucket.
resource "aws_s3_bucket" "terraform_state" {
  bucket = "jasmin-terraform-state-bucket"

  tags = {
    Name = "jasmin Terraform State Bucket"
  }
}
State Locking with DynamoDB:
- Create a DynamoDB table using Terraform (or manually if required) to store the state lock information.
Configure Terraform to use this DynamoDB table for state locking.
- Terraform Module Creation:
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "jasmin-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key   = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform State Lock Table"
  }
}
![img-1](<Screenshot from 2024-08-21 22-55-01.png>)
![img-2](<Screenshot from 2024-08-21 22-55-15.png>)
![img-3](<Screenshot from 2024-08-21 22-57-03.png>)
![img-4](<Screenshot from 2024-08-21 22-57-20.png>)
Custom Module:
Create a Terraform module to deploy the following AWS resources:
EC2 instance: Use an AMI for the region and allow SSH access using a security group.
create main.tf

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  security_groups = [aws_security_group.allow_ssh.name]

  tags = {
    Name = join("-", [var.instance_name, "server"])
  }
}

create outputs.tf

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

create variables.tf
variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "region" {
  description = "The AWS region to deploy the resources"
  type        = string
  default     = "ap-south-1"
}

variable "instance_name" {
  description = "A name prefix for the EC2 instance"
  type        = string
  default     = "app"
}
S3 bucket: Create an S3 bucket for application data.
Use Terraform variables (txvars) to parameterize important aspects such as:
Instance Type: Allow the instance type to be configurable (e.g., t2.micro).
Region: Parameterize the AWS region so that the module can be reused across regions.
Bucket Name: Use a variable to set the S3 bucket name.
create main.tf
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
create outputs.tf
output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.app_bucket.bucket
}
create variables.tf
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}
- Terraform Functions:
Use Terraform functions in your module to manipulate and process the variables. For example:
Use join to combine strings for resource names.
Use lookup to set default values if a variable is not provided.
Use length to count the number of instances or resources.
Input Variables and Configuration (txvars):
- Define input variables to make the infrastructure flexible:
EC2 instance type.
S3 bucket name.
AWS region.
Any other variable relevant to the infrastructure.
Use the default argument for variables where appropriate.
- Output Configuration:
Set up Terraform outputs to display key information after the infrastructure is created:
EC2 Public IP: Output the public IP of the EC2 instance.
S3 Bucket Name: Output the name of the S3 bucket created.
Region: Output the region where the resources were deployed.
create main.tf
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
create outputs.tf
output "instance_id" {
  value = module.ec2.instance_id
}

output "bucket_name" {
  value = module.s3.bucket_name
}
create variables.tf
variable "bucket" {
  type    = string
  default = "jasmin-new-bucket"
}

variable "instance_name" {
  type    = string
  default = "jasmin-app"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "region" {
  type    = string
  default = "us-east-1"
}
- Initial Deployment:
Use terraform plan and terraform apply to deploy the infrastructure.
Verify that the EC2 instance, S3 bucket, and all configurations are properly set up.
Infrastructure Changes:
Modify one of the variables (e.g., change the instance type or add tags) and re-run terraform apply.
Observe how Terraform plans and applies only the necessary changes, with state locking in effect.
![img-6](<Screenshot from 2024-08-20 16-57-22.png>)
![img-7](<Screenshot from 2024-08-29 11-21-48.png>)

