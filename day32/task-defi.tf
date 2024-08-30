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
