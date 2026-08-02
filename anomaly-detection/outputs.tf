output "anomaly_monitor_arn" {
  description = "ARN of the AWS Cost Anomaly Monitor."
  value       = aws_ce_anomaly_monitor.account.arn
}

output "anomaly_subscription_arn" {
  description = "ARN of the AWS Cost Anomaly Subscription."
  value       = aws_ce_anomaly_subscription.account.arn
}
