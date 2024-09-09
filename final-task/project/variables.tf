variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "ap-northeast-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

# Add more variables as needed
