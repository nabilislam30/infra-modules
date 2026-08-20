# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name used for compute, Auto Scaling, and load balancing resources."
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to compute resources."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Network
# -----------------------------------------------------------------------------

variable "vpc_id" {
  description = "ID of the VPC where compute resources are deployed."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs used by the Application Load Balancer."
  type        = list(string)
}

# -----------------------------------------------------------------------------
# Golden AMI
# -----------------------------------------------------------------------------

variable "ami_id" {
  description = "Golden AMI ID consumed by the launch template."
  type        = string
}

# -----------------------------------------------------------------------------
# EC2
# -----------------------------------------------------------------------------

variable "instance_type" {
  description = "EC2 instance type used by the Auto Scaling Group."
  type        = string
}

# -----------------------------------------------------------------------------
# Auto Scaling
# -----------------------------------------------------------------------------

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling Group."
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group."
  type        = number
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group."
  type        = number
}

# -----------------------------------------------------------------------------
# Application
# -----------------------------------------------------------------------------

variable "application_port" {
  description = "Port used by the application and target group."
  type        = number
}

variable "health_check_path" {
  description = "HTTP health check path used by the target group."
  type        = string
}

# -----------------------------------------------------------------------------
# Dev SSH Learning Mode
# -----------------------------------------------------------------------------

variable "enable_ssh" {
  description = "Whether SSH access is enabled for development learning mode."
  type        = bool
  default     = false
}

variable "key_name" {
  description = "EC2 key pair name used when SSH learning mode is enabled."
  type        = string
  default     = null
}

variable "my_ip" {
  description = "Public IPv4 address allowed to use SSH when development learning mode is enabled."
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Compute Networking
# -----------------------------------------------------------------------------

variable "compute_subnet_ids" {
  description = "Subnet IDs used by the Auto Scaling Group instances."
  type        = list(string)
}

variable "associate_public_ip_address" {
  description = "Whether compute instances receive a public IPv4 address."
  type        = bool
  default     = false
}

variable "database_security_group_id" {
  description = "Security group ID of the database allowed to receive PostgreSQL traffic from compute instances."
  type        = string
}

variable "database_secret_arn" {
  description = "ARN of the RDS-managed Secrets Manager secret readable by compute instances."
  type        = string
}

variable "database_secret_kms_key_arn" {
  description = "ARN of the KMS key used to encrypt the RDS-managed Secrets Manager secret."
  type        = string
}
