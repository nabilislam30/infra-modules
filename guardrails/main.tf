/*
----------------------------------------------------------------------------
Phase 2 - Guardrails Module

This module implements account-level IAM guardrails for a single AWS account.

Controls include:
- Restricting access to approved AWS regions
- Protecting core security services
- Preventing IAM user and long-term credential creation
- Applying a permission boundary to human roles
- Providing a read-only developer role
- Separating environments using resource tags
- Enforcing the Environment tag during supported resource creation actions
----------------------------------------------------------------------------
*/

###############################################################
# AWS Account Information
###############################################################

data "aws_caller_identity" "current" {}


###############################################################
# Deny Unapproved AWS Regions
###############################################################

data "aws_iam_policy_document" "deny_unapproved_regions" {
  statement {
    sid    = "DenyUnapprovedRegions"
    effect = "Deny"

    actions = [
      "*"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"

      values = [
        "eu-west-2",
        "eu-west-1"
      ]
    }
  }
}


###############################################################
# Protect Core Security Services
###############################################################

data "aws_iam_policy_document" "protect_security_services" {
  statement {
    sid    = "DenySecurityServiceDisablement"
    effect = "Deny"

    actions = [
      "cloudtrail:DeleteTrail",
      "cloudtrail:StopLogging",
      "cloudtrail:UpdateTrail",

      "config:DeleteConfigurationRecorder",
      "config:DeleteDeliveryChannel",
      "config:StopConfigurationRecorder",

      "guardduty:DeleteDetector",
      "guardduty:UpdateDetector",

      "securityhub:DisableSecurityHub",
      "securityhub:UpdateSecurityHubConfiguration"
    ]

    resources = [
      "*"
    ]
  }
}


###############################################################
# Prevent IAM User and Long-Term Credential Creation
###############################################################

data "aws_iam_policy_document" "deny_iam_user_creation" {
  statement {
    sid    = "DenyIAMUserCreation"
    effect = "Deny"

    actions = [
      "iam:CreateUser",
      "iam:CreateAccessKey",
      "iam:CreateLoginProfile"
    ]

    resources = [
      "*"
    ]
  }
}


###############################################################
# DevelopersRO Trust Policy
###############################################################

data "aws_iam_policy_document" "developers_ro_assume_role" {
  statement {
    sid    = "AllowAccountPrincipalsToAssumeRole"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}


###############################################################
# Permission Boundary
###############################################################

data "aws_iam_policy_document" "permission_boundary" {
  statement {
    sid    = "AllowApprovedPermissions"
    effect = "Allow"

    actions = [
      "*"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "DenyUnapprovedRegions"
    effect = "Deny"

    actions = [
      "*"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"

      values = [
        "eu-west-2",
        "eu-west-1"
      ]
    }
  }

  statement {
    sid    = "DenySecurityServiceDisablement"
    effect = "Deny"

    actions = [
      "cloudtrail:DeleteTrail",
      "cloudtrail:StopLogging",
      "cloudtrail:UpdateTrail",

      "config:DeleteConfigurationRecorder",
      "config:DeleteDeliveryChannel",
      "config:StopConfigurationRecorder",

      "guardduty:DeleteDetector",
      "guardduty:UpdateDetector",

      "securityhub:DisableSecurityHub",
      "securityhub:UpdateSecurityHubConfiguration"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "DenyIAMUserCreation"
    effect = "Deny"

    actions = [
      "iam:CreateUser",
      "iam:CreateAccessKey",
      "iam:CreateLoginProfile"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "DenyCrossEnvironmentAccess"
    effect = "Deny"

    actions = [
      "*"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringNotEquals"
      variable = "aws:ResourceTag/Environment"

      values = [
        "dev"
      ]
    }

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/Environment"

      values = [
        "false"
      ]
    }
  }

  statement {
    sid    = "DenyResourceCreationWithoutDevTag"
    effect = "Deny"

    actions = [
      "ec2:RunInstances",
      "rds:CreateDBInstance",
      "rds:CreateDBCluster",
      "lambda:CreateFunction"
    ]

    resources = [
      "*"
    ]

    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestTag/Environment"

      values = [
        "dev"
      ]
    }
  }
}


###############################################################
# AWS-Managed IAM Policy Lookup
###############################################################

data "aws_iam_policy" "read_only_access" {
  name = "ReadOnlyAccess"
}


###############################################################
# Managed Guardrail Policies
###############################################################

resource "aws_iam_policy" "deny_unapproved_regions" {
  name        = "DenyUnapprovedRegions"
  description = "Deny all actions in unapproved regions"
  policy      = data.aws_iam_policy_document.deny_unapproved_regions.json

  tags = {
    ManagedBy   = "Terraform"
    Project     = "Guardrails"
    Environment = "global"
  }
}

resource "aws_iam_policy" "protect_security_services" {
  name        = "ProtectSecurityServices"
  description = "Deny actions that would disable security services"
  policy      = data.aws_iam_policy_document.protect_security_services.json

  tags = {
    ManagedBy   = "Terraform"
    Project     = "Guardrails"
    Environment = "global"
  }
}

resource "aws_iam_policy" "deny_iam_user_creation" {
  name        = "DenyIAMUserCreation"
  description = "Deny creation of IAM users and long-term credentials"
  policy      = data.aws_iam_policy_document.deny_iam_user_creation.json

  tags = {
    ManagedBy   = "Terraform"
    Project     = "Guardrails"
    Environment = "global"
  }
}

resource "aws_iam_policy" "permission_boundary" {
  name        = "TerraformManagedRolePermissionBoundary"
  description = "Maximum permissions boundary for IAM roles managed through Terraform."
  policy      = data.aws_iam_policy_document.permission_boundary.json

  tags = {
    ManagedBy   = "Terraform"
    Project     = "Guardrails"
    Environment = "global"
  }
}


###############################################################
# Developers Read-Only Role
###############################################################

resource "aws_iam_role" "developers_ro" {
  name                 = var.developers_ro_role_name
  assume_role_policy   = data.aws_iam_policy_document.developers_ro_assume_role.json
  permissions_boundary = aws_iam_policy.permission_boundary.arn

  tags = {
    ManagedBy   = "Terraform"
    Project     = "Guardrails"
    Environment = "dev"
    Access      = "ReadOnly"
  }
}

resource "aws_iam_role_policy_attachment" "developers_ro_read_only" {
  role       = aws_iam_role.developers_ro.name
  policy_arn = data.aws_iam_policy.read_only_access.arn
}
