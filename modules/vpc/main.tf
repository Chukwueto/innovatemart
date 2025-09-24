# VPC Configuration
resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr  #TODO: Define vpc CIDR in variables.tf
  enable_dns_hostnames = true  #Allows DNS resolution with the VPC
  enable_dns_support   = true  #Enables DNS support for EC2 instances

  tags = {
    project     = "EKS-Cluster"
    Environment = "Dev"  #TODO: Modify the environment tag
  }
}


# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]  #TODO

  map_public_ip_on_launch = true  #Automatically assign a public IP address to instances

  tags = {
    Name = "public-subnet-${count.index + 1}"  #TODO: Customize naming pattern
    Tier = "public"
  }
}


# Private Subnets
resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidr)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.private_subnet_cidr[count.index]
  availability_zone       = var.availability_zones[count.index]  #TODO

  map_public_ip_on_launch = false  

  tags = {
    Name = "private-subnet-${count.index + 1}"  #TODO: Customize naming pattern
    Tier = "private"
  }
}


# internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "my_vpc_igw"  #TODO:Add tag name
  }
}



# Elastic IPs
resource "aws_eip" "eip-nat" {
  domain = "vpc"

  # TODO: Optionally add tags here for better resource tracking
}



# NAT Gateway
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip-nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "nat-gw"
  }
}



# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"  # Allows all outbound traffic
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = ""  #TODO: Add tag name
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "private-RT"  #TODO: Customize prefix or suffix if needed
  }
}  


resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}



