output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "instance_id" {
  description = "Instance ID"
  value       = module.compute.instance_id
}

output "s3_bucket" {
  description = "S3 Bucket"
  value       = module.storage.bucket_id
}
