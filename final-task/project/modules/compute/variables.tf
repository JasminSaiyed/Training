variable "vpc_id" {
  description = "VPC ID where the instance will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be deployed"
  type        = string
}
variable "ami_id" {
  description = "The AMI ID to use for the EC2 instances"
  type        = string
}
