# VPC Name
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

# Public Subnet Name
variable "public_subnet_cidr" {
  description = "public subnet CIDR block"
  type        = list(string)
}

# Private Subnet Name
variable "private_subnet_cidr" {
  description = "private subnet CIDR block"
  type        = list(string)
}

# Availability Zones
variable "availability_zones" {
  description = "Availbility zones"
  type        = list(string)
}

