resource "aws_ce_anomaly_monitor" "account" {
  name              = var.monitor_name
  monitor_type      = "DIMENSIONAL"
  monitor_dimension = "SERVICE"
}

resource "aws_ce_anomaly_subscription" "account" {
  name      = var.subscription_name
  frequency = "DAILY"

  monitor_arn_list = [
    aws_ce_anomaly_monitor.account.arn
  ]

  subscriber {
    type    = "EMAIL"
    address = var.notification_email
  }

  threshold_expression {
    dimension {
      key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
      values        = [tostring(var.threshold_usd)]
      match_options = ["GREATER_THAN_OR_EQUAL"]
    }
  }
}
