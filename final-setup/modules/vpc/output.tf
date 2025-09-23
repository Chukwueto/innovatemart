# VPC ID output is essential for associating other resources within the vpc
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.eks_vpc.id
}

# Public Subnet IDs are required for routing internet-facing traffic and public services
output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

# Private Subnet IDs are necessary for isolating internal resources and worker nodes
output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}
