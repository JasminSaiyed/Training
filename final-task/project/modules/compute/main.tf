resource "aws_instance" "this" {
  ami           = "ami-0cab37bd176bb80d3"
  instance_type = "t2.micro"
  subnet_id     = var.subnet_id

  tags = {
    Name = "Kubernetes-Node"
  }

}

output "instance_id" {
  value = aws_instance.this.id
}

