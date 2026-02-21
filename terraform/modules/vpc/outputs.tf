output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = aws_vpc.this.cidr_block
}

output "azs" {
  description = "Availability Zones used"
  value       = local.azs
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = [for s in aws_subnet.private : s.id]
}

output "public_subnet_map" {
  description = "Map of AZ => public subnet ID"
  value       = { for az, s in aws_subnet.public : az => s.id }
}

output "private_subnet_map" {
  description = "Map of AZ => private subnet ID"
  value       = { for az, s in aws_subnet.private : az => s.id }
}

output "nat_gateway_ids" {
  description = "Map of AZ => NAT Gateway ID"
  value       = { for az, ngw in aws_nat_gateway.this : az => ngw.id }
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.this.id
}

output "nat_enabled" {
  description = "Whether NAT Gateways are enabled"
  value       = var.enable_nat_gateway
}

output "single_nat_gateway" {
  description = "Whether using a single NAT Gateway (when enabled)"
  value       = var.single_nat_gateway
}
