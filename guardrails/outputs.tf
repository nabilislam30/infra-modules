output "deny_unapproved_regions_policy_arn" {
  description = "ARN of the IAM policy that denies actions in unapproved regions."
  value       = aws_iam_policy.deny_unapproved_regions.arn
}

output "protect_security_services_policy_arn" {
  description = "ARN of the IAM policy that protects security services."
  value       = aws_iam_policy.protect_security_services.arn
}

output "deny_iam_user_creation_policy_arn" {
  description = "ARN of the IAM policy that denies creation of IAM users and long-term credentials."
  value       = aws_iam_policy.deny_iam_user_creation.arn
}

output "permission_boundary_policy_arn" {
  description = "ARN of the IAM policy that serves as a permission boundary"
  value       = aws_iam_policy.permission_boundary.arn
}

output "dev_deployment_permission_boundary_policy_arn" {
  description = "ARN of the permission boundary for the dev Terraform deployment role."
  value       = aws_iam_policy.dev_deployment_permission_boundary.arn
}

output "staging_deployment_permission_boundary_policy_arn" {
  description = "ARN of the permission boundary for the staging Terraform deployment role."
  value       = aws_iam_policy.staging_deployment_permission_boundary.arn
}

output "prod_deployment_permission_boundary_policy_arn" {
  description = "ARN of the permission boundary for the prod Terraform deployment role."
  value       = aws_iam_policy.prod_deployment_permission_boundary.arn
}
