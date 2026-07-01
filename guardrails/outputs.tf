/*
Outputs will be added as guardrail resources are implemented.
*/

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
