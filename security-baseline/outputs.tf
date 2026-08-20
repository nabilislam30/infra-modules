# -----------------------------------------------------------------------------
# GuardDuty
# -----------------------------------------------------------------------------

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector."
  value       = aws_guardduty_detector.this.id
}

# -----------------------------------------------------------------------------
# IAM Access Analyzer
# -----------------------------------------------------------------------------

output "access_analyzer_arn" {
  description = "The ARN of the IAM Access Analyzer."
  value       = aws_accessanalyzer_analyzer.this.arn
}

# -----------------------------------------------------------------------------
# CloudTrail
# -----------------------------------------------------------------------------

output "cloudtrail_log_group_name" {
  description = "The name of the CloudWatch Log Group used by CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_logs_bucket_arn" {
  description = "ARN of the central S3 bucket used for CloudTrail and VPC Flow Logs."
  value       = aws_s3_bucket.cloudtrail_logs.arn
}

# -----------------------------------------------------------------------------
# KMS
# -----------------------------------------------------------------------------

output "logs_kms_key_arn" {
  description = "ARN of the customer-managed KMS key used for security baseline logs."
  value       = aws_kms_key.logs.arn
}
