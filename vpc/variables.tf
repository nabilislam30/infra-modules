variable "name" {
  description = "Name used to identify the VPC and its resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block assigned to the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Three Availability Zones used by the VPC."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 3
    error_message = "Exactly three Availability Zones must be provided."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the three public subnets."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == 3
    error_message = "Exactly three public subnet CIDRs must be provided."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the three private subnets."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_cidrs) == 3
    error_message = "Exactly three private subnet CIDRs must be provided."
  }
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for the three database subnets."
  type        = list(string)

  validation {
    condition     = length(var.database_subnet_cidrs) == 3
    error_message = "Exactly three database subnet CIDRs must be provided."
  }
}

variable "common_tags" {
  description = "Common tags applied to supported VPC resources."
  type        = map(string)
  default     = {}
}

variable "nat_gateway_strategy" {
  description = "NAT Gateway strategy. Use single for one shared NAT Gateway or per_az for one NAT Gateway per Availability Zone."
  type        = string

  validation {
    condition = contains(
      [
        "single",
        "per_az"
      ],
      var.nat_gateway_strategy
    )

    error_message = "nat_gateway_strategy must be either single or per_az."
  }
}

variable "aws_region" {
  description = "AWS Region used to construct VPC endpoint service names."
  type        = string
}
