/*
----------------------------------------------------------------------------
Phase 2 - Guardrails Module

This module implements account-level guardrails for a single AWS account.

Resources will be added incrementally to reduce deployment risk.
----------------------------------------------------------------------------
*/

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

resource "aws_iam_policy" "deny_unapproved_regions" {
  name        = "DenyUnapprovedRegions"
  description = "Deny all actions in unapproved regions"
  policy      = data.aws_iam_policy_document.deny_unapproved_regions.json

  tags = {
    ManagedBy = "Terraform"
    project   = "Guardrails"
  }
}

resource "aws_iam_policy" "protect_security-services" {
  name        = "ProtectSecurityServices"
  description = "Deny actions that would disable security services"
  policy      = data.aws_iam_policy_document.protect_security_services.json

  tags = {
    ManagedBy = "Terraform"
    project   = "Guardrails"

  }
}

resource "aws_iam_policy" "deny_iam_user_creation" {
  name        = "DenyIAMUserCreation"
  description = "Deny creation of IAM users and long-term credentials"
  policy      = data.aws_iam_policy_document.deny_iam_user_creation.json

  tags = {
    ManagedBy = "Terraform"
    Project   = "Guardrails"
  }
}
