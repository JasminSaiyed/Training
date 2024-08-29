output "instance_ids" {
  value = aws_instance.jasmin_app[*].id
}
