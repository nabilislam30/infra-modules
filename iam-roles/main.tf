# -----------------------------------------------------------------------------
# GitHub Actions OIDC Provider
# -----------------------------------------------------------------------------

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

# -----------------------------------------------------------------------------
# GitHub OIDC Trust Policies
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "dev_deploy_role_trust" {
  statement {
    sid    = "AllowGitHubOIDC"
    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:nabilislam30/infra-live:*"
      ]
    }
  }
}

data "aws_iam_policy_document" "staging_deploy_role_trust" {
  statement {
    sid    = "AllowGitHubOIDC"
    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:nabilislam30/infra-live:*"
      ]
    }
  }
}

data "aws_iam_policy_document" "prod_deploy_role_trust" {
  statement {
    sid    = "AllowGitHubOIDCFromMain"
    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:nabilislam30/infra-live:ref:refs/heads/main"
      ]
    }
  }
}

# -----------------------------------------------------------------------------
# Deployment Tag Permissions
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "tag_permissions" {
  statement {
    effect = "Allow"

    actions = [
      "logs:TagResource",
      "config:TagResource",
      "guardduty:TagResource",
      "access-analyzer:TagResource"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "tag_permissions" {
  name        = "TerraformDeployTagPermissions"
  description = "Allows deployment roles to tag supported AWS resources."

  policy = data.aws_iam_policy_document.tag_permissions.json
}

# -----------------------------------------------------------------------------
# Deployment Read Permissions
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "read_permissions" {
  statement {
    effect = "Allow"

    actions = [
      "logs:ListTagsForResource",
      "logs:DescribeLogGroups",
      "config:DescribeConfigurationRecorderStatus",
      "config:StopConfigurationRecorder",
      "config:StartConfigurationRecorder",
      "config:ListTagsForResource"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "read_permissions" {
  name        = "TerraformDeployReadPermissions"
  description = "Provides the existing Terraform deployment read and AWS Config recorder permissions."

  policy = data.aws_iam_policy_document.read_permissions.json
}
resource "aws_iam_role_policy_attachment" "dev_read_permissions" {
  role       = aws_iam_role.dev.name
  policy_arn = aws_iam_policy.read_permissions.arn
}

resource "aws_iam_role_policy_attachment" "staging_read_permissions" {
  role       = aws_iam_role.staging.name
  policy_arn = aws_iam_policy.read_permissions.arn
}

resource "aws_iam_role_policy_attachment" "prod_read_permissions" {
  role       = aws_iam_role.prod.name
  policy_arn = aws_iam_policy.read_permissions.arn
}

# -----------------------------------------------------------------------------
# Config Remediation Permissions
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "config_remediation_permissions" {
  statement {
    sid    = "ManageConfigRemediation"
    effect = "Allow"

    actions = [
      "config:PutRemediationConfigurations",
      "config:DescribeRemediationConfigurations",
      "config:DeleteRemediationConfiguration",
      "config:DescribeRemediationExecutionStatus"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "config_remediation_permissions" {
  name        = "TerraformDeployConfigRemediationAccess"
  description = "Allows Terraform deployment roles to manage AWS Config remediation configurations."

  policy = data.aws_iam_policy_document.config_remediation_permissions.json
}
resource "aws_iam_role_policy_attachment" "dev_config_remediation_permissions" {
  role       = aws_iam_role.dev.name
  policy_arn = aws_iam_policy.config_remediation_permissions.arn
}

resource "aws_iam_role_policy_attachment" "staging_config_remediation_permissions" {
  role       = aws_iam_role.staging.name
  policy_arn = aws_iam_policy.config_remediation_permissions.arn
}

resource "aws_iam_role_policy_attachment" "prod_config_remediation_permissions" {
  role       = aws_iam_role.prod.name
  policy_arn = aws_iam_policy.config_remediation_permissions.arn
}

# -----------------------------------------------------------------------------
# Monitoring Deployment Permissions
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "monitoring_permissions" {
  statement {
    sid    = "ManageMonitoringSnsTopic"
    effect = "Allow"

    actions = [
      "sns:CreateTopic",
      "sns:DeleteTopic",
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:ListTagsForResource",
      "sns:TagResource",
      "sns:UntagResource",
      "sns:Subscribe",
      "sns:Unsubscribe",
      "sns:GetSubscriptionAttributes",
      "sns:ListSubscriptionsByTopic"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageCloudTrailMetricFilters"
    effect = "Allow"

    actions = [
      "logs:PutMetricFilter",
      "logs:DeleteMetricFilter",
      "logs:DescribeMetricFilters",
      "logs:TestMetricFilter"
    ]

    resources = [
      "arn:aws:logs:eu-west-2:442847318797:log-group:/aws/cloudtrail/account-baseline:*"
    ]
  }

  statement {
    sid    = "ManageCloudWatchMonitoringAlarms"
    effect = "Allow"

    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:TagResource",
      "cloudwatch:UntagResource",
      "cloudwatch:ListTagsForResource"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "monitoring_permissions" {
  name        = "TerraformDeployMonitoringAccess"
  description = "Allows Terraform deployment roles to manage monitoring and alerting resources."

  policy = data.aws_iam_policy_document.monitoring_permissions.json
}

resource "aws_iam_role_policy_attachment" "dev_monitoring_permissions" {
  role       = aws_iam_role.dev.name
  policy_arn = aws_iam_policy.monitoring_permissions.arn
}

resource "aws_iam_role_policy_attachment" "staging_monitoring_permissions" {
  role       = aws_iam_role.staging.name
  policy_arn = aws_iam_policy.monitoring_permissions.arn
}

resource "aws_iam_role_policy_attachment" "prod_monitoring_permissions" {
  role       = aws_iam_role.prod.name
  policy_arn = aws_iam_policy.monitoring_permissions.arn
}

# -----------------------------------------------------------------------------
# Cost Management Permissions
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "cost_management_permissions" {
  statement {
    sid    = "ManageAWSBudgets"
    effect = "Allow"

    actions = [
      "budgets:ModifyBudget",
      "budgets:ViewBudget",
      "budgets:TagResource",
      "budgets:UntagResource",
      "budgets:ListTagsForResource"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageBillingAccess"
    effect = "Allow"

    actions = [
      "billing:GetBillingViewData",
      "aws-portal:ViewBilling",
      "aws-portal:ModifyBilling"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageCostAnomalyDetection"
    effect = "Allow"

    actions = [
      "ce:CreateAnomalyMonitor",
      "ce:GetAnomalyMonitors",
      "ce:UpdateAnomalyMonitor",
      "ce:DeleteAnomalyMonitor",
      "ce:CreateAnomalySubscription",
      "ce:GetAnomalySubscriptions",
      "ce:UpdateAnomalySubscription",
      "ce:DeleteAnomalySubscription",
      "ce:TagResource",
      "ce:UntagResource",
      "ce:ListTagsForResource"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "cost_management_permissions" {
  name        = "TerraformDeployCostManagementAccess"
  description = "Allows Terraform deployment roles to manage AWS Budgets, billing access, and Cost Anomaly Detection."

  policy = data.aws_iam_policy_document.cost_management_permissions.json
}

resource "aws_iam_role_policy_attachment" "dev_cost_management_permissions" {
  role       = aws_iam_role.dev.name
  policy_arn = aws_iam_policy.cost_management_permissions.arn
}

resource "aws_iam_role_policy_attachment" "staging_cost_management_permissions" {
  role       = aws_iam_role.staging.name
  policy_arn = aws_iam_policy.cost_management_permissions.arn
}

resource "aws_iam_role_policy_attachment" "prod_cost_management_permissions" {
  role       = aws_iam_role.prod.name
  policy_arn = aws_iam_policy.cost_management_permissions.arn
}

# -----------------------------------------------------------------------------
# VPC Deployment Permissions
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "vpc_deployment_permissions" {
  statement {
    sid    = "ManageVpcNetworking"
    effect = "Allow"

    actions = [
      "ec2:CreateVpc",
      "ec2:DeleteVpc",
      "ec2:DescribeVpcs",
      "ec2:ModifyVpcAttribute",
      "ec2:CreateSubnet",
      "ec2:DeleteSubnet",
      "ec2:DescribeSubnets",
      "ec2:ModifySubnetAttribute",
      "ec2:CreateInternetGateway",
      "ec2:DeleteInternetGateway",
      "ec2:AttachInternetGateway",
      "ec2:DetachInternetGateway",
      "ec2:DescribeInternetGateways",
      "ec2:AllocateAddress",
      "ec2:ReleaseAddress",
      "ec2:DescribeAddresses",
      "ec2:CreateNatGateway",
      "ec2:DeleteNatGateway",
      "ec2:DescribeNatGateways",
      "ec2:CreateRouteTable",
      "ec2:DeleteRouteTable",
      "ec2:DescribeRouteTables",
      "ec2:AssociateRouteTable",
      "ec2:DisassociateRouteTable",
      "ec2:CreateRoute",
      "ec2:DeleteRoute",
      "ec2:ReplaceRoute",
      "ec2:ReplaceRouteTableAssociation",
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup",
      "ec2:DescribeSecurityGroups",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:CreateVpcEndpoint",
      "ec2:DeleteVpcEndpoints",
      "ec2:DescribeVpcEndpoints",
      "ec2:ModifyVpcEndpoint",
      "ec2:DescribeVpcEndpointServices",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:DescribeTags",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateFlowLogs",
      "ec2:DescribeFlowLogs",
      "ec2:DeleteFlowLogs"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageRdsSubnetGroups"
    effect = "Allow"

    actions = [
      "rds:CreateDBSubnetGroup",
      "rds:DescribeDBSubnetGroups",
      "rds:ModifyDBSubnetGroup",
      "rds:DeleteDBSubnetGroup",
      "rds:AddTagsToResource",
      "rds:RemoveTagsFromResource",
      "rds:ListTagsForResource"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageFlowLogDelivery"
    effect = "Allow"

    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "vpc_deployment_permissions" {
  name        = "TerraformDeployVpcAccess"
  description = "Allows Terraform deployment roles to manage VPC networking, database subnet groups, and VPC Flow Logs."

  policy = data.aws_iam_policy_document.vpc_deployment_permissions.json
}

resource "aws_iam_role_policy_attachment" "dev_vpc_deployment_permissions" {
  role       = aws_iam_role.dev.name
  policy_arn = aws_iam_policy.vpc_deployment_permissions.arn
}

resource "aws_iam_role_policy_attachment" "staging_vpc_deployment_permissions" {
  role       = aws_iam_role.staging.name
  policy_arn = aws_iam_policy.vpc_deployment_permissions.arn
}

resource "aws_iam_role_policy_attachment" "prod_vpc_deployment_permissions" {
  role       = aws_iam_role.prod.name
  policy_arn = aws_iam_policy.vpc_deployment_permissions.arn
}

# -----------------------------------------------------------------------------
# Terraform Deployment Roles
# -----------------------------------------------------------------------------
resource "aws_iam_role" "dev" {
  name                 = "tf-deploy-dev"
  assume_role_policy   = data.aws_iam_policy_document.dev_deploy_role_trust.json
  permissions_boundary = var.permission_boundary_policy_arn

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "DevOps-Starter"
  }
}

resource "aws_iam_role" "staging" {
  name                 = "tf-deploy-staging"
  assume_role_policy   = data.aws_iam_policy_document.staging_deploy_role_trust.json
  permissions_boundary = var.permission_boundary_policy_arn

  tags = {
    Environment = "staging"
    ManagedBy   = "Terraform"
    Project     = "DevOps-Starter"
  }
}

resource "aws_iam_role" "prod" {
  name                 = "tf-deploy-prod"
  assume_role_policy   = data.aws_iam_policy_document.prod_deploy_role_trust.json
  permissions_boundary = var.permission_boundary_policy_arn

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
    Project     = "DevOps-Starter"
  }
}

# -----------------------------------------------------------------------------
# Existing Phase 2 Guardrail Attachments - Dev
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "dev_deny_unapproved_regions" {
  role       = aws_iam_role.dev.name
  policy_arn = var.deny_unapproved_regions_policy_arn
}

resource "aws_iam_role_policy_attachment" "dev_protect_security_services" {
  role       = aws_iam_role.dev.name
  policy_arn = var.protect_security_services_policy_arn
}

resource "aws_iam_role_policy_attachment" "dev_deny_iam_user_creation" {
  role       = aws_iam_role.dev.name
  policy_arn = var.deny_iam_user_creation_policy_arn
}

# -----------------------------------------------------------------------------
# Existing Phase 2 Guardrail Attachments - Staging
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "staging_deny_unapproved_regions" {
  role       = aws_iam_role.staging.name
  policy_arn = var.deny_unapproved_regions_policy_arn
}

resource "aws_iam_role_policy_attachment" "staging_protect_security_services" {
  role       = aws_iam_role.staging.name
  policy_arn = var.protect_security_services_policy_arn
}

resource "aws_iam_role_policy_attachment" "staging_deny_iam_user_creation" {
  role       = aws_iam_role.staging.name
  policy_arn = var.deny_iam_user_creation_policy_arn
}

# -----------------------------------------------------------------------------
# Existing Phase 2 Guardrail Attachments - Prod
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "prod_deny_unapproved_regions" {
  role       = aws_iam_role.prod.name
  policy_arn = var.deny_unapproved_regions_policy_arn
}

resource "aws_iam_role_policy_attachment" "prod_protect_security_services" {
  role       = aws_iam_role.prod.name
  policy_arn = var.protect_security_services_policy_arn
}

resource "aws_iam_role_policy_attachment" "prod_deny_iam_user_creation" {
  role       = aws_iam_role.prod.name
  policy_arn = var.deny_iam_user_creation_policy_arn
}

# -----------------------------------------------------------------------------
# Deployment Tag Permission Attachments
# -----------------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "dev_tag_permissions" {
  role       = aws_iam_role.dev.name
  policy_arn = aws_iam_policy.tag_permissions.arn
}

resource "aws_iam_role_policy_attachment" "staging_tag_permissions" {
  role       = aws_iam_role.staging.name
  policy_arn = aws_iam_policy.tag_permissions.arn
}

resource "aws_iam_role_policy_attachment" "prod_tag_permissions" {
  role       = aws_iam_role.prod.name
  policy_arn = aws_iam_policy.tag_permissions.arn
}
