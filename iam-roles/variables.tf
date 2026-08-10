variable "permission_boundary_policy_arn" {
  description = "ARN of the Phase 2 permission boundary policy."
  type        = string
}

variable "deny_unapproved_regions_policy_arn" {
  description = "ARN of the Phase 2 policy that denies actions in unapproved AWS Regions."
  type        = string
}

variable "protect_security_services_policy_arn" {
  description = "ARN of the Phase 2 policy that protects security services."
  type        = string
}

variable "deny_iam_user_creation_policy_arn" {
  description = "ARN of the Phase 2 policy that denies IAM user and long-term credential creation."
  type        = string
}
