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
