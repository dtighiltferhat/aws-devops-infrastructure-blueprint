output "db_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.this.endpoint
}

output "db_address" {
  description = "Database hostname/address"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Database port"
  value       = aws_db_instance.this.port
}

output "db_sg_id" {
  description = "Database security group ID"
  value       = aws_security_group.db.id
}

output "db_subnet_group" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.this.name
}

output "db_identifier" {
  value = aws_db_instance.this.id
}
