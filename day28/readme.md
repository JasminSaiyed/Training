Project Objective:
This project will assess your ability to deploy a multi-tier architecture application on AWS using Terraform. The deployment will involve using Terraform variables, outputs, and change sets. The multi-tier architecture will include an EC2 instance, an RDS MySQL DB instance, and an S3 bucket.
+ Project Overview:
You are required to write Terraform configuration files to automate the deployment of a multi-tier application on AWS. The architecture should consist of:
EC2 Instance: A t2.micro instance serving as the application server.
RDS MySQL DB Instance: A t3.micro instance for the database backend.
S3 Bucket: For storing static assets or configuration files.
Specifications:
EC2 Instance: Use the t2.micro instance type with a public IP, allowing HTTP and SSH access.
RDS MySQL DB Instance: Use the t3.micro instance type with a publicly accessible endpoint.
S3 Bucket: Use for storing static assets, configuration files, or backups.
Terraform Configuration:
Utilize Terraform variables to parameterize the deployment (e.g., instance type, database name).
Use Terraform outputs to display important information (e.g., EC2 public IP, RDS endpoint).
Implement change sets to demonstrate how Terraform manages infrastructure changes.
No Terraform Modules: Focus solely on the core Terraform configurations without custom or external modules.
Key Tasks:
Setup Terraform Configuration:
Provider Configuration:
Configure the AWS provider to specify the region for deployment.
+ Ensure the region is parameterized using a Terraform variable.
VPC and Security Groups:
Create a VPC with a public subnet for the EC2 instance.
Define security groups allowing HTTP and SSH access to the EC2 instance, and MySQL access to the RDS instance.
+ EC2 Instance:
Define the EC2 instance using a t2.micro instance type.
Configure the instance to allow SSH and HTTP access.
Use Terraform variables to define instance parameters like AMI ID and instance type.
RDS MySQL DB Instance:
Create a t3.micro MySQL DB instance within the same VPC.
Use Terraform variables to define DB parameters like DB name, username, and password.
Ensure the DB instance is publicly accessible, and configure security groups to allow access from the EC2 instance.
+ S3 Bucket:
Create an S3 bucket for storing static files or configurations.
Allow the EC2 instance to access the S3 bucket by assigning the appropriate IAM role and policy.
Outputs:
Define Terraform outputs to display the EC2 instance’s public IP address, the RDS instance’s endpoint, and the S3 bucket name.
Apply and Manage Infrastructure:
+ Initial Deployment:
Run terraform init to initialize the configuration.
Use terraform plan to review the infrastructure changes before applying.
Deploy the infrastructure using terraform apply, and ensure that the application server, database, and S3 bucket are set up correctly.
![img-1](<Screenshot from 2024-08-20 15-21-07.png>)
provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-2"
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default     = "ami-000a81e3bab21747d"
}

variable "db_name" {
  description = "The name of the RDS MySQL database"
  type        = string
  default     = "mydatabase"
}

variable "db_username" {
  description = "The username for the RDS MySQL database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "The password for the RDS MySQL database"
  type        = string
  sensitive   = true
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket (must be globally unique)"
  type        = string
  default     = "unique-bucket-name-1234567890" # Update this with a unique bucket name
}

# VPC and Subnets
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
}

# Security Groups
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.public_a.id
  security_groups = [aws_security_group.ec2_sg.name]

  tags = {
    Name = "WebServerInstance"
  }
}

# RDS MySQL DB Instance
resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name = "MySQLInstance"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

# S3 Bucket and ACL
resource "aws_s3_bucket" "static_files" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_acl" "static_files_acl" {
  bucket = aws_s3_bucket.static_files.id
  acl    = "private"
}

resource "aws_iam_role" "s3_access_role" {
  name = "s3AccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_access_policy" {
  name = "s3AccessPolicy"
  role = aws_iam_role.s3_access_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = "arn:aws:s3:::${aws_s3_bucket.static_files.bucket}/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "s3AccessProfile"
  role = aws_iam_role.s3_access_role.name
}

# Outputs
output "ec2_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "s3_bucket_name" {
  value = aws_s3_bucket.static_files.bucket
}
perform terraform plan
![img-2](<Screenshot from 2024-08-20 16-48-28.png>)
![img-3](<Screenshot from 2024-08-20 16-48-39.png>)
perform terraform apply
![img-4](<Screenshot from 2024-08-20 16-57-34.png>)
![img-5](<Screenshot from 2024-08-20 18-00-05.png>)
Testing and Validation:
Validate the setup by:
Accessing the EC2 instance via SSH and HTTP.
Connecting to the MySQL DB instance from the EC2 instance.
Verifying that the EC2 instance can read and write to the S3 bucket.
Check the Terraform outputs to ensure they correctly display the relevant information.
![img-6](<Screenshot from 2024-08-21 12-29-50.png>)
![img-7](<Screenshot from 2024-08-21 12-30-30.png>)
![img-8](<Screenshot from 2024-08-21 12-31-04.png>)
![img-9](<Screenshot from 2024-08-21 12-31-29.png>)
![img-10](<Screenshot from 2024-08-21 12-32-12.png>)
Resource Termination:
Once the deployment is complete and validated, run terraform destroy to tear down all the resources created by Terraform.
Confirm that all AWS resources (EC2 instance, RDS DB, S3 bucket, VPC) are properly deleted.
![img-11](<Screenshot from 2024-08-20 18-00-41.png>)
![img-12](<Screenshot from 2024-08-20 18-01-29.png>)
