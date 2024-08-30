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
