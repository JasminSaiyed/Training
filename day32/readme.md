Deploying a Multi-Tier Web Application Using Amazon ECS (Without Load Balancer and API Gateway)
Project Overview
This project is designed to test your knowledge of Amazon ECS (Elastic Container Service) by deploying a multi-tier web application on AWS without using a Load Balancer or API Gateway. The project involves setting up an ECS cluster, defining task definitions, creating services, and ensuring proper networking and security configurations using VPC, subnets, security groups, and IAM roles.

Project Objectives
Set up an ECS Cluster using the Fargate launch type.
Deploy a web application consisting of multiple containers (frontend and backend).
Implement direct communication between frontend and backend services.
Manage ECS tasks, services, and scaling policies.
Ensure network security with VPC, subnets, security groups, and IAM roles.
Project Requirements
ECS Cluster

Create an ECS Cluster using the Fargate launch type.
Task Definitions

Define task definitions for web and backend services.
Services

Create ECS services for each tier (frontend and backend) without using a Load Balancer or API Gateway.
Security Groups

Configure security groups to allow traffic between services directly.
IAM Roles

Create and assign IAM roles for ECS tasks.
VPC and Networking

Create a VPC with public and private subnets, ensuring proper routing of traffic without a NAT gateway.
Secrets Management

Use AWS Secrets Manager or SSM Parameter Store to manage database credentials.
Scaling

Implement auto-scaling policies for the ECS services.
Project Deliverables
ECS Cluster Setup
Create an ECS cluster using the Fargate launch type.

create rds.tf
# RDS MySQL Instance
resource "aws_db_instance" "mysql" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = "<db-name>"
  username             = "<db-username>"
  password             = "<db-password>"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible = false
  skip_final_snapshot = true
  tags = {
    Name = "RDS-jasmin"
  }
}
![img-1](<Screenshot from 2024-08-30 10-43-21.png>)
create ecs.tf
# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "my-cluster-jasmin"
}

# Secret Manager
resource "aws_secretsmanager_secret" "db_secret" {
  name = "DB-day32-jasmin"
}
 
resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({ password = "<your-db-password>" })
}

# Frontend Service
resource "aws_ecs_service" "frontend" {
  name            = "frontend-service-chirag"
  cluster         = aws_ecs_cluster.main.id
  desired_count   = 1
  launch_type = "FARGATE"
  task_definition = aws_ecs_task_definition.frontend.arn

  network_configuration {
    subnets         = [aws_subnet.public_subnet.id]
    security_groups = [aws_security_group.frontend.id]
    assign_public_ip = true
  }
  tags = {
    Name = "jasmin-frontend-service"
  }
}

# Backend Service
resource "aws_ecs_service" "backend" {
  name            = "backend-service-chirag"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  launch_type = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets         = [aws_subnet.private1.id, aws_subnet.private2.id]
    security_groups = [aws_security_group.backend.id]
  }
  tags = {
    Name = "jasmin-backend-service"
  }
}
create vpc.tf
# Provider Configuration
provider "aws" {
  region = "us-west-2"
}

# VPC Setup
resource "aws_vpc" "my_vpc" {
  cidr_block = "<vpc-cidr>"
  tags = {
    Name = "jasmin-vpc"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyIGW-chirag"
  }
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "<subnet-cidr>"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-sub-jasmin"
  }
}


resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "<subnet-cidr>"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = false
  tags = {
    Name = "pri1-sub-jasmin"
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "<subnet-cidr>"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = false
  tags = {
    Name = "pri2-sub-jasmin"
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "Pub-RT-jasmin"
  }
}

# Create a route table for the private subnet
resource "aws_route_table" "private_rt" {
    vpc_id = aws_vpc.my_vpc.id
    
    tags = {
        Name = "Pri-RT-jasmin"
    }
}

# create subnet group of private subnet1 and private subnet2
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds_subnet_group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
  tags = {
    Name = "RDS Subnet Group"
  }
}

# Associate the private subnet 1 with the private route table

resource "aws_route_table_association" "private_rt_assoc1" {
    subnet_id      = aws_subnet.private1.id    
    route_table_id = aws_route_table.private_rt.id
}

# Associate the private subnet 2 with the private route table

resource "aws_route_table_association" "private_rt_assoc2" {
    subnet_id      = aws_subnet.private2.id    
    route_table_id = aws_route_table.private_rt.id
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
create security_group.tf
# Security Groups
resource "aws_security_group" "frontend" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "frontend-sg-chirag"
  }
}

resource "aws_security_group" "backend" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    security_groups = [aws_security_group.frontend.id]
  }

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
  tags = {
    Name = "backend-sg-chirag"
  }
}

resource "aws_security_group" "db" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.backend.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "db-sg-jasmin"
  }
}
create task-defi.tf
# Frontend Service Task Definition
resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  tags = {
    Name = "jasmin-frontend-task-def"
  }

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "<frontend-docker-image>"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
  execution_role_arn = aws_iam_role.ecs_task_role.arn
}

# Backend Service Task Definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "backend-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  tags = {
    Name = "jasmin-backend-task-def"
  }

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "<backend-docker-image>"
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      environment = [
        {
          name  = "DB_HOST"
          value = "${aws_db_instance.mysql.endpoint}"
        },
        {
          name  = "DB_USER"
          value = "<username>"
        },
        {
          name  = "DB_PASS"
          value = "${aws_secretsmanager_secret_version.db_secret_version.secret_string}"
        }
      ]
      secrets = [
        {
          name      = "db_pass_jasmin"
          valueFrom = "${aws_secretsmanager_secret_version.db_secret_version.arn}"
        }
      ]
    }
  ])
  execution_role_arn = aws_iam_role.ecs_task_role.arn
}

frontend
![img-2](<Screenshot from 2024-08-30 10-44-58.png>)
backend
![img-3](<Screenshot from 2024-08-30 10-47-05.png>)
# Create IAM Role
resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
  tags = {
    Name = "jasmin-ecs-task-role"
  }
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
![img-4](<Screenshot from 2024-08-30 10-51-07.png>)
![img-5](<Screenshot from 2024-08-30 11-06-20.png>)
create autoscaling.tf
 Auto Scaling (Example for Frontend)
resource "aws_appautoscaling_target" "frontend_scaling_target" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.frontend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  tags = {
    Name = "jasmin-autoscaling-target"
  }
}

resource "aws_appautoscaling_policy" "frontend_scaling_policy" {
  name                   = "frontend-scaling-policy"
  policy_type            = "TargetTrackingScaling"
  resource_id            = aws_appautoscaling_target.frontend_scaling_target.resource_id
  scalable_dimension     = aws_appautoscaling_target.frontend_scaling_target.scalable_dimension
  service_namespace      = aws_appautoscaling_target.frontend_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 50.0
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}


Resource Cleanup
Once the deployment is validated, ensure that all AWS resources are properly terminated:
Stop and delete ECS tasks and services.
Delete the ECS cluster.
Terminate the RDS instance.
Clean up any associated S3 buckets, IAM roles, and security groups.
$ terraform destroy => destroy.log

