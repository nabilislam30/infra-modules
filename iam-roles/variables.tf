variable "dev_permission_boundary_policy_arn" {
  description = "ARN of the dev deployment role permission boundary policy."
  type        = string
}

variable "staging_permission_boundary_policy_arn" {
  description = "ARN of the staging deployment role permission boundary policy."
  type        = string
}

variable "prod_permission_boundary_policy_arn" {
  description = "ARN of the prod deployment role permission boundary policy."
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
