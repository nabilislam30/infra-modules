/*
----------------------------------------------------------------------------
Phase 2 - Guardrails Module

This module implements account-level IAM guardrails for a single AWS account.

The module creates:
- Region restriction policy
- Security service protection policy
- IAM user creation restriction policy
- Combined permission boundary
- Read-only developer IAM role
----------------------------------------------------------------------------
*/

###############################################################
# Current AWS Account
###############################################################

data "aws_caller_identity" "current" {}

###############################################################
# IAM Policy Documents
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

      "securityhub:DisableSecurityHub"
    ]

    resources = [
      "*"
    ]
  }
}

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

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
  }
}

###############################################################
# Permission Boundary Policy Document
###############################################################

data "aws_iam_policy_document" "permission_boundary" {
  statement {
    sid    = "AllowActionsWithinBoundary"
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

      "securityhub:DisableSecurityHub"
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
}

###############################################################
# AWS-Managed IAM Policy Lookup
###############################################################

data "aws_iam_policy" "read_only_access" {
  name = "ReadOnlyAccess"
}

###############################################################
# IAM Managed Policies
###############################################################

resource "aws_iam_policy" "deny_unapproved_regions" {
  name        = "DenyUnapprovedRegions"
  description = "Denies actions in AWS regions that have not been approved."
  policy      = data.aws_iam_policy_document.deny_unapproved_regions.json

  tags = {
    ManagedBy = "Terraform"
    Project   = "Guardrails"
  }
}

resource "aws_iam_policy" "protect_security_services" {
  name        = "ProtectSecurityServices"
  description = "Prevents core AWS security services from being disabled or deleted."
  policy      = data.aws_iam_policy_document.protect_security_services.json

  tags = {
    ManagedBy = "Terraform"
    Project   = "Guardrails"
  }
}

resource "aws_iam_policy" "deny_iam_user_creation" {
  name        = "DenyIAMUserCreation"
  description = "Prevents the creation of IAM users and long-term user credentials."
  policy      = data.aws_iam_policy_document.deny_iam_user_creation.json

  tags = {
    ManagedBy = "Terraform"
    Project   = "Guardrails"
  }
}

resource "aws_iam_policy" "permission_boundary" {
  name        = "TerraformManagedRolePermissionBoundary"
  description = "Maximum permissions boundary for IAM roles managed through Terraform."
  policy      = data.aws_iam_policy_document.permission_boundary.json

  tags = {
    ManagedBy = "Terraform"
    Project   = "Guardrails"
  }
}

###############################################################
# Read-Only Developer Role
###############################################################

resource "aws_iam_role" "developers_ro" {
  name                 = var.developers_ro_role_name
  assume_role_policy   = data.aws_iam_policy_document.developers_ro_assume_role.json
  permissions_boundary = aws_iam_policy.permission_boundary.arn

  tags = {
    ManagedBy = "Terraform"
    Project   = "Guardrails"
    Access    = "ReadOnly"
  }
}

###############################################################
# IAM Role Policy Attachments
###############################################################

resource "aws_iam_role_policy_attachment" "developers_ro_read_only" {
  role       = aws_iam_role.developers_ro.name
  policy_arn = data.aws_iam_policy.read_only_access.arn
}
