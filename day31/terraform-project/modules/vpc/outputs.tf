output "vpc_id" {
  value = aws_vpc.jasmin_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.jasmin_public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.jasmin_private[*].id
}
