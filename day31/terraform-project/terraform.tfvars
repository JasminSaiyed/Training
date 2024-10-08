vpc_cidr          = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones = ["us-west-2a", "us-west-2b"]
instance_type     = "t2.micro"
ami_id            = "ami-05134c8ef96964280"
db_username       = "admin"
db_password       = "password"
s3_bucket_prefix  = "jasmin-terraform-bucket"
