/*
Input variables will be added as guardrail resources are implemented.
*/
variable "developers_ro_role_name" {
  description = "Name of the IAM role for read-only developers."
  type        = string
  default     = "DevelopersRO"
}
