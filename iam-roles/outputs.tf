output "tf_deploy_dev_role_arn" {
  description = "ARN of the Terraform dev deployment role."
  value       = aws_iam_role.dev.arn
}

output "tf_deploy_staging_role_arn" {
  description = "ARN of the Terraform staging deployment role."
  value       = aws_iam_role.staging.arn
}

output "tf_deploy_prod_role_arn" {
  description = "ARN of the Terraform production deployment role."
  value       = aws_iam_role.prod.arn
}
