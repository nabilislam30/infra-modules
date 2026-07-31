locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_sns_topic" "monitoring_alerts" {
  name = "${local.name_prefix}-alerts"

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

# -----------------------------------------------------------------------------
# Out-of-Band Infrastructure Change Detection
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "unapproved_assumed_role_changes" {
  name        = "${local.name_prefix}-unapproved-role-changes"
  description = "Detects mutating AWS API calls made by unapproved assumed roles."

  event_pattern = jsonencode({
    detail-type = [
      "AWS API Call via CloudTrail"
    ]

    detail = {
      readOnly = [
        false
      ]

      userIdentity = {
        type = [
          "AssumedRole"
        ]

        sessionContext = {
          sessionIssuer = {
            arn = [
              {
                anything-but = tolist(var.deployment_role_arns)
              }
            ]
          }
        }
      }
    }
  })

  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "unapproved_assumed_role_changes" {
  rule      = aws_cloudwatch_event_rule.unapproved_assumed_role_changes.name
  target_id = "SendToMonitoringSns"
  arn       = aws_sns_topic.monitoring_alerts.arn
}

resource "aws_cloudwatch_event_rule" "direct_identity_changes" {
  name        = "${local.name_prefix}-direct-identity-changes"
  description = "Detects mutating AWS API calls made directly by root or IAM identities."

  event_pattern = jsonencode({
    detail-type = [
      "AWS API Call via CloudTrail"
    ]

    detail = {
      readOnly = [
        false
      ]

      userIdentity = {
        type = [
          "Root",
          "IAMUser",
          "FederatedUser"
        ]
      }
    }
  })

  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "direct_identity_changes" {
  rule      = aws_cloudwatch_event_rule.direct_identity_changes.name
  target_id = "SendToMonitoringSns"
  arn       = aws_sns_topic.monitoring_alerts.arn
}

data "aws_iam_policy_document" "monitoring_sns" {
  statement {
    sid    = "AllowEventBridgeToPublish"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "events.amazonaws.com"
      ]
    }

    actions = [
      "sns:Publish"
    ]

    resources = [
      aws_sns_topic.monitoring_alerts.arn
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        aws_cloudwatch_event_rule.unapproved_assumed_role_changes.arn,
        aws_cloudwatch_event_rule.direct_identity_changes.arn
      ]
    }
  }
}

resource "aws_sns_topic_policy" "monitoring_alerts" {
  arn    = aws_sns_topic.monitoring_alerts.arn
  policy = data.aws_iam_policy_document.monitoring_sns.json
}
