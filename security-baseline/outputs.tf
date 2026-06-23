output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector."
  value       = aws_guardduty_detector.this.id
}

output "access_analyzer_arn" {
  description = "The ARN of the IAM Access Analyzer."
  value       = aws_accessanalyzer_analyzer.this.arn
}
