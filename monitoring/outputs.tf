output "sns_topic_arn" {
  description = "SNS Topic ARN used for monitoring alerts."
  value       = aws_sns_topic.monitoring_alerts.arn
}

output "sns_topic_name" {
  description = "SNS Topic name."
  value       = aws_sns_topic.monitoring_alerts.name
}

output "cloudwatch_alarm_arns" {
  description = "ARNs of the CloudWatch security alarms."

  value = {
    root_account_usage     = aws_cloudwatch_metric_alarm.root_account_usage.arn
    console_login_failure  = aws_cloudwatch_metric_alarm.console_login_failure.arn
    unauthorised_api_calls = aws_cloudwatch_metric_alarm.unauthorised_api_calls.arn
    security_group_changes = aws_cloudwatch_metric_alarm.security_group_changes.arn
    iam_policy_changes     = aws_cloudwatch_metric_alarm.iam_policy_changes.arn
  }
}
