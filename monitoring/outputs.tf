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

output "out_of_band_event_rule_arns" {
  description = "ARNs of the EventBridge rules used to detect out-of-band infrastructure changes."

  value = {
    unapproved_assumed_roles = aws_cloudwatch_event_rule.unapproved_assumed_role_changes.arn
    direct_identities        = aws_cloudwatch_event_rule.direct_identity_changes.arn
  }
}
