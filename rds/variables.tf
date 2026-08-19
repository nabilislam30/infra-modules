# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name prefix used for RDS resources."
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to RDS resources."
  type        = map(string)
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------

variable "vpc_id" {
  description = "ID of the VPC where the database is deployed."
  type        = string
}

variable "database_subnet_ids" {
  description = "Subnet IDs used by the RDS database subnet group."
  type        = list(string)
}

variable "compute_security_group_id" {
  description = "Security group ID of the compute instances allowed to access PostgreSQL."
  type        = string
}

# -----------------------------------------------------------------------------
# PostgreSQL
# -----------------------------------------------------------------------------

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "allocated_storage" {
  description = "Allocated database storage in GiB."
  type        = number
}

variable "database_name" {
  description = "Initial PostgreSQL database name."
  type        = string
}

variable "master_username" {
  description = "Master username for the PostgreSQL database."
  type        = string
}

# -----------------------------------------------------------------------------
# Backup and Availability
# -----------------------------------------------------------------------------

variable "backup_retention_period" {
  description = "Number of days automated backups are retained."
  type        = number
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled."
  type        = bool
  default     = true
}

variable "multi_az" {
  description = "Whether the RDS instance is deployed across multiple Availability Zones."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Performance Insights
# -----------------------------------------------------------------------------

variable "performance_insights_kms_key_id" {
  description = "ARN of the customer-managed KMS key used to encrypt RDS Performance Insights data."
  type        = string
}
