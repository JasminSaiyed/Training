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
