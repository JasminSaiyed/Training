1. Infrastructure Design
The project will involve deploying a basic 3-tier web application architecture, which includes the following components:
VPC: Create a Virtual Private Cloud (VPC) with public and private subnets across two availability zones.
Security Groups: Define security groups to control inbound and outbound traffic for the application and database tiers.
EC2 Instances: Deploy EC2 instances in the public subnets for the web servers (Application Tier).
RDS Instance: Deploy an RDS MySQL instance in the private subnet for the database (Database Tier).
S3 Bucket: Create an S3 bucket to store static files, with versioning enabled.
Elastic IPs: Assign Elastic IPs to the EC2 instances.
IAM Role: Create an IAM role with the necessary permissions and attach it to the EC2 instances.
create main.tf
provider "aws" {
  region = "us-west-2"
  profile = var.aws_profile
}

terraform {
  backend "s3" {
    bucket         = "jas-bucket"
    key            = "terraform/state.tfstate"
    region         = "us-west-2"
    dynamodb_table = "jasmin_terraform_lock-table"
    encrypt        = true
  }
}

module "vpc" {
  source = "./modules/vpc"
  cidr_block = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones = var.availability_zones
}

module "ec2" {
  source = "./modules/ec2"
  ami_id = var.ami_id
  instance_type = var.instance_type
  instance_count = 2
  public_subnet_ids = module.vpc.public_subnet_ids
  key_name = "example"
  security_group_id = module.security_group.sg_id
}

module "rds" {
  source = "./modules/rds"
  db_username = var.db_username
  db_password = var.db_password
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id = module.vpc.vpc_id
}

module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
}

2. Terraform State Management
●       Implement remote state storage using an S3 bucket to store the Terraform state file.
●       Use DynamoDB for state locking to prevent concurrent modifications.
create state directory
create main.tf
provider "aws" {
  region = "us-west-2"
  
}

resource "aws_s3_bucket" "jasmin_bucket" {
  bucket ="jasmin-bucket"
  versioning {
    enabled = true
  }

  tags = {
    Name = "jasmin-s3-bucket"

  }
}

resource "aws_dynamodb_table" "jasmin_terraform_lock" {
  name           = "jasmin_terraform_lock-table"
  read_capacity   = 5
  write_capacity  = 5
  hash_key        = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "jasmin-terraform-lock-table"
  }
}

3. Variables and tfvars
●       Define input variables for resources like VPC CIDR, instance types, database username/password, and S3 bucket names.
●       Use .tfvars files to pass different configurations for environments (e.g., dev.tfvars, prod.tfvars).
create variables.tf
variable "vpc_cidr" {
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
create terraform.tfvars
vpc_cidr          = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones = ["us-west-2a", "us-west-2b"]
instance_type     = "t2.micro"
ami_id            = "ami-05134c8ef96964280"
db_username       = "admin"
db_password       = "password"
s3_bucket_prefix  = "jasmin-terraform-bucket"

create dev.tfvars
vpc_cidr          = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones = ["us-west-2a", "us-west-2b"]
instance_type     = "t2.micro"
ami_id            = "ami-05134c8ef96964280"
db_username       = "user"
db_password       = "password"
s3_bucket_prefix  = "jasmin-dev-bucket"
create prod.tfvars
vpc_cidr          = "10.1.0.0/16"
public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]
availability_zones = ["us-west-2a", "us-west-2b"]
instance_type     = "t3.micro"
ami_id            = "ami-05134c8ef96964280"
db_username       = "root"
db_password       = "password"
s3_bucket_prefix  = "jasmin-prod-bucket"
4. Modules
●       Break down the infrastructure into reusable modules:
○       VPC Module: Manage VPC, subnets, and routing tables.
○       EC2 Module: Configure and launch EC2 instances.
○       RDS Module: Set up the RDS MySQL database.
○       S3 Module: Handle S3 bucket creation with versioning.
○       IAM Module: Create and manage IAM roles and policies.
+ create module for ec2
- Create main.tf
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
- create outputs.tf
output "instance_ids" {
  value = aws_instance.jasmin_app[*].id
}
- create variables.tf
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
+ create modules for s3
- create main.tf
resource "aws_s3_bucket" "jasmin_bucket" {
  bucket_prefix = var.bucket_prefix
  versioning {
    enabled = true
  }

  tags = {
    Name = "jasmin-s3-bucket"
  }
}
- create outputs.tf
output "bucket_name" {
  value = aws_s3_bucket.jasmin_bucket.bucket
}
- create variables.tf
variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
}
+ create modules for rds
- create main.tf
resource "aws_db_instance" "jasmin_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name                 = "jasmin"
  username             = var.db_username
  password             = var.db_password
  vpc_security_group_ids = [aws_security_group.jasmin_db_sg.id]
  db_subnet_group_name = aws_db_subnet_group.jasmin_db_subnet_group.name
  skip_final_snapshot  = true

  tags = {
    Name = "jasmin-db-instance"
  }
}

resource "aws_db_subnet_group" "jasmin_db_subnet_group" {
  name       = "jasmin-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags = {
    Name = "jasmin-db-subnet-group"
  }
}

resource "aws_security_group" "jasmin_db_sg" {
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "jasmin-db-sg"
  }
}
- create outputs.tf
output "db_instance_endpoint" {
  value = aws_db_instance.jasmin_db.endpoint
}
- create variables.tf
variable "db_username" {
  description = "Database username"
  type        = string
  
}

variable "db_password" {
  description = "Database password"
  type        = string
  
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}
+ create modules for iam
- create main.tf
resource "aws_iam_role" "jasmin_ec2_role" {
  name = "jasmin-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "jasmin-ec2-role"
  }
}

resource "aws_iam_role_policy_attachment" "jasmin_ec2_policy_attachment" {
  role       = aws_iam_role.jasmin_ec2_role.name
  policy_arn  = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}
- create outputs.tf
output "iam_role_arn" {
  value = aws_iam_role.jasmin_ec2_role.arn
}
+ create modules for security group
- create main.tf
resource "aws_security_group" "jasmin_sg" {
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jasmin-sg"
  }
}
- create outputs.tf
output "sg_id" {
  value = aws_security_group.jasmin_sg.id
}
- create variables.tf
variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}
+ create vpc 
- create main.tf
  cidr_block = var.cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "jasmin-main-vpc"
  }


resource "aws_subnet" "jasmin_public" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.jasmin_vpc.id
  cidr_block = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "jasmin-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "jasmin_private" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.jasmin_vpc.id
  cidr_block = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name = "jasmin-private-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "jasmin_igw" {
  vpc_id = aws_vpc.jasmin_vpc.id
  tags = {
    Name = "jasmin-main-igw"
  }
}

resource "aws_route_table" "jasmin_public" {
  vpc_id = aws_vpc.jasmin_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jasmin_igw.id
  }
  tags = {
    Name = "jasmin-public-route-table"
  }
}

resource "aws_route_table_association" "jasmin_public" {
  count = length(aws_subnet.jasmin_public)
  subnet_id = element(aws_subnet.jasmin_public.*.id, count.index)
  route_table_id = aws_route_table.jasmin_public.id
}
output "vpc_id" {
  value = aws_vpc.jasmin_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.jasmin_public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.jasmin_private[*].id
}
variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}
![img-1](<Screenshot from 2024-08-23 15-26-05.png>)
![img-2](<Screenshot from 2024-08-28 15-47-59.png>)
![img-3](<Screenshot from 2024-08-23 15-26-59.png>)
7. Lifecycle Rules
●       Implement lifecycle rules to:
○       Prevent resource deletion: Ensure certain resources, like the RDS database, are not accidentally deleted (prevent_destroy).
○       Ignore changes to specific resource attributes (e.g., S3 bucket tags) using ignore_changes.
