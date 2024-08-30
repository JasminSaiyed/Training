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
