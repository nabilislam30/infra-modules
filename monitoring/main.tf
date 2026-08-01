locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# -----------------------------------------------------------------------------
# SNS Monitoring Notifications
# -----------------------------------------------------------------------------

resource "aws_sns_topic" "monitoring_alerts" {
  name              = "${local.name_prefix}-alerts"
  kms_master_key_id = "alias/aws/sns"

  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-alerts"
    }
  )
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.monitoring_alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email_endpoint
}

# -----------------------------------------------------------------------------
# CloudTrail Metric Filters
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_metric_filter" "root_account_usage" {
  name           = "${local.name_prefix}-root-account-usage"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"

  metric_transformation {
    name          = "RootAccountUsage"
    namespace     = var.metric_namespace
    value         = "1"
    default_value = 0
  }
}

resource "aws_cloudwatch_log_metric_filter" "console_login_failure" {
  name           = "${local.name_prefix}-console-login-failure"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{ $.eventName = \"ConsoleLogin\" && $.errorMessage = \"Failed authentication\" }"

  metric_transformation {
    name          = "ConsoleLoginFailure"
    namespace     = var.metric_namespace
    value         = "1"
    default_value = 0
  }
}

resource "aws_cloudwatch_log_metric_filter" "unauthorised_api_calls" {
  name           = "${local.name_prefix}-unauthorised-api-calls"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{ ($.errorCode = \"*UnauthorizedOperation\") || ($.errorCode = \"AccessDenied*\") }"

  metric_transformation {
    name          = "UnauthorisedApiCalls"
    namespace     = var.metric_namespace
    value         = "1"
    default_value = 0
  }
}

resource "aws_cloudwatch_log_metric_filter" "security_group_changes" {
  name           = "${local.name_prefix}-security-group-changes"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{ ($.eventName = \"AuthorizeSecurityGroupIngress\") || ($.eventName = \"AuthorizeSecurityGroupEgress\") || ($.eventName = \"RevokeSecurityGroupIngress\") || ($.eventName = \"RevokeSecurityGroupEgress\") || ($.eventName = \"CreateSecurityGroup\") || ($.eventName = \"DeleteSecurityGroup\") || ($.eventName = \"UpdateSecurityGroupRuleDescriptionsIngress\") || ($.eventName = \"UpdateSecurityGroupRuleDescriptionsEgress\") }"

  metric_transformation {
    name          = "SecurityGroupChanges"
    namespace     = var.metric_namespace
    value         = "1"
    default_value = 0
  }
}

resource "aws_cloudwatch_log_metric_filter" "iam_policy_changes" {
  name           = "${local.name_prefix}-iam-policy-changes"
  log_group_name = var.cloudtrail_log_group_name

  pattern = "{ ($.eventName = \"DeleteGroupPolicy\") || ($.eventName = \"DeleteRolePolicy\") || ($.eventName = \"DeleteUserPolicy\") || ($.eventName = \"PutGroupPolicy\") || ($.eventName = \"PutRolePolicy\") || ($.eventName = \"PutUserPolicy\") || ($.eventName = \"CreatePolicy\") || ($.eventName = \"DeletePolicy\") || ($.eventName = \"CreatePolicyVersion\") || ($.eventName = \"DeletePolicyVersion\") || ($.eventName = \"AttachRolePolicy\") || ($.eventName = \"DetachRolePolicy\") || ($.eventName = \"AttachUserPolicy\") || ($.eventName = \"DetachUserPolicy\") || ($.eventName = \"AttachGroupPolicy\") || ($.eventName = \"DetachGroupPolicy\") }"

  metric_transformation {
    name          = "IamPolicyChanges"
    namespace     = var.metric_namespace
    value         = "1"
    default_value = 0
  }
}

# -----------------------------------------------------------------------------
# CloudWatch Alarms
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "root_account_usage" {
  alarm_name          = "${local.name_prefix}-root-account-usage"
  alarm_description   = "Triggers when the AWS root account is used."
  namespace           = var.metric_namespace
  metric_name         = aws_cloudwatch_log_metric_filter.root_account_usage.metric_transformation[0].name
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.monitoring_alerts.arn
  ]

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "console_login_failure" {
  alarm_name          = "${local.name_prefix}-console-login-failure"
  alarm_description   = "Triggers when an AWS Management Console login fails."
  namespace           = var.metric_namespace
  metric_name         = aws_cloudwatch_log_metric_filter.console_login_failure.metric_transformation[0].name
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.monitoring_alerts.arn
  ]

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "unauthorised_api_calls" {
  alarm_name          = "${local.name_prefix}-unauthorised-api-calls"
  alarm_description   = "Triggers when unauthorised AWS API calls are detected."
  namespace           = var.metric_namespace
  metric_name         = aws_cloudwatch_log_metric_filter.unauthorised_api_calls.metric_transformation[0].name
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.monitoring_alerts.arn
  ]

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "security_group_changes" {
  alarm_name          = "${local.name_prefix}-security-group-changes"
  alarm_description   = "Triggers when security group configuration changes."
  namespace           = var.metric_namespace
  metric_name         = aws_cloudwatch_log_metric_filter.security_group_changes.metric_transformation[0].name
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.monitoring_alerts.arn
  ]

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "iam_policy_changes" {
  alarm_name          = "${local.name_prefix}-iam-policy-changes"
  alarm_description   = "Triggers when IAM policies or policy attachments change."
  namespace           = var.metric_namespace
  metric_name         = aws_cloudwatch_log_metric_filter.iam_policy_changes.metric_transformation[0].name
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [
    aws_sns_topic.monitoring_alerts.arn
  ]

  tags = var.common_tags
}
