# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------

variable "name" {
  description = "Name used for the EC2 Image Builder resources."
  type        = string
}

variable "common_tags" {
  description = "Common tags applied to EC2 Image Builder resources."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Golden AMI Source
# -----------------------------------------------------------------------------

variable "parent_image" {
  description = "Parent image ARN or AMI ID used as the base for the Golden AMI."
  type        = string
}

variable "recipe_version" {
  description = "Version of the EC2 Image Builder image recipe."
  type        = string
}

# -----------------------------------------------------------------------------
# Image Builder Component
# -----------------------------------------------------------------------------

variable "component_version" {
  description = "Version of the EC2 Image Builder component."
  type        = string
}

variable "component_document" {
  description = "YAML document containing the Golden AMI build and hardening steps."
  type        = string
}

# -----------------------------------------------------------------------------
# Build Infrastructure
# -----------------------------------------------------------------------------

variable "instance_type" {
  description = "EC2 instance type used to build and test the Golden AMI."
  type        = string
}

variable "subnet_id" {
  description = "Subnet used by the EC2 Image Builder build instance."
  type        = string
}

variable "security_group_ids" {
  description = "Security groups attached to the EC2 Image Builder build instance."
  type        = list(string)
}

# -----------------------------------------------------------------------------
# Distribution
# -----------------------------------------------------------------------------

variable "distribution_region" {
  description = "AWS Region where the Golden AMI is distributed."
  type        = string
}
