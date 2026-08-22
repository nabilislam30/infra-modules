# -----------------------------------------------------------------------------
# Production Terraform Plan Role - GitHub Pull Requests
# -----------------------------------------------------------------------------

# The production deployment role is intentionally restricted to the main branch.
# Pull-request planning therefore uses a separate role that can read production
# infrastructure and acquire the Terraform state lock, but cannot modify AWS
# infrastructure.

data "aws_iam_policy_document" "prod_plan_role_trust" {
  statement {
    sid    = "AllowGitHubOIDCFromPullRequests"
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
        "repo:nabilislam30/infra-live:pull_request"
      ]
    }
  }
}

resource "aws_iam_role" "prod_plan" {
  name                 = "tf-plan-prod"
  assume_role_policy   = data.aws_iam_policy_document.prod_plan_role_trust.json
  permissions_boundary = var.prod_permission_boundary_policy_arn

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
    Project     = "DevOps-Starter"
    Purpose     = "TerraformPlan"
  }
}

# AWS managed ReadOnlyAccess is used only by the production planning role.
# The production permission boundary still restricts access to prod/global
# resources and approved AWS Regions.
resource "aws_iam_role_policy_attachment" "prod_plan_read_only" {
  role       = aws_iam_role.prod_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Terraform takes a short-lived DynamoDB lock even for a read-only plan.
# This policy grants only the lock operations required by the S3 backend;
# it does not grant permission to write Terraform state or AWS resources.
data "aws_iam_policy_document" "prod_plan_backend_lock" {
  statement {
    sid    = "ManageTerraformStateLock"
    effect = "Allow"

    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]

    resources = [
      "arn:aws:dynamodb:eu-west-2:442847318797:table/terraform-state-locks"
    ]
  }
}

resource "aws_iam_policy" "prod_plan_backend_lock" {
  name        = "TerraformPlanProdBackendLock"
  description = "Allows the production Terraform plan role to acquire and release the remote state lock."

  policy = data.aws_iam_policy_document.prod_plan_backend_lock.json
}

resource "aws_iam_role_policy_attachment" "prod_plan_backend_lock" {
  role       = aws_iam_role.prod_plan.name
  policy_arn = aws_iam_policy.prod_plan_backend_lock.arn
}
