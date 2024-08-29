resource "aws_vpc" "jasmin_vpc" {
  cidr_block = var.cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "jasmin-main-vpc"
  }
}

resource "aws_subnet" "jasmin_public" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.jasmin_vpc.id
  cidr_block = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "jasmin-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "jasmin_private" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.jasmin_vpc.id
  cidr_block = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name = "jasmin-private-subnet-${count.index}"
  }
}

resource "aws_internet_gateway" "jasmin_igw" {
  vpc_id = aws_vpc.jasmin_vpc.id
  tags = {
    Name = "jasmin-main-igw"
  }
}

resource "aws_route_table" "jasmin_public" {
  vpc_id = aws_vpc.jasmin_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jasmin_igw.id
  }
  tags = {
    Name = "jasmin-public-route-table"
  }
}

resource "aws_route_table_association" "jasmin_public" {
  count = length(aws_subnet.jasmin_public)
  subnet_id = element(aws_subnet.jasmin_public.*.id, count.index)
  route_table_id = aws_route_table.jasmin_public.id
}
