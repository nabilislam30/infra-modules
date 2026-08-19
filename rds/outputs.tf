# -----------------------------------------------------------------------------
# RDS Instance
# -----------------------------------------------------------------------------

output "db_instance_id" {
  description = "ID of the PostgreSQL RDS instance."
  value       = aws_db_instance.this.id
}

output "db_instance_arn" {
  description = "ARN of the PostgreSQL RDS instance."
  value       = aws_db_instance.this.arn
}

output "db_endpoint" {
  description = "Connection endpoint of the PostgreSQL RDS instance."
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Port used by the PostgreSQL RDS instance."
  value       = aws_db_instance.this.port
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------

output "database_security_group_id" {
  description = "Security group ID attached to the PostgreSQL RDS instance."
  value       = aws_security_group.database.id
}

output "db_subnet_group_name" {
  description = "Name of the RDS database subnet group."
  value       = aws_db_subnet_group.this.name
}

# -----------------------------------------------------------------------------
# Secrets Manager
# -----------------------------------------------------------------------------

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret managed by RDS for the master user."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
