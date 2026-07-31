output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector."
  value       = aws_guardduty_detector.this.id
}

output "access_analyzer_arn" {
  description = "The ARN of the IAM Access Analyzer."
  value       = aws_accessanalyzer_analyzer.this.arn
}

output "cloudtrail_log_group_name" {
  description = "The name of the CloudWatch Log Group used by CloudTrail."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}
