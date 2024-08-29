variable "bucket" {
  type    = string
  default = "jasmin-new-bucket"
}

variable "instance_name" {
  type    = string
  default = "jasmin-app"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "region" {
  type    = string
  default = "us-east-1"
}
