# -----------------------------------------------------------------------------
# Staging Terraform Backend Permissions
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "staging_backend_permissions" {
  statement {
    sid    = "ListTerraformStateBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::fimatix-devops-starter-tfstate-442847318797"
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "staging/*",
        "global/terraform.tfstate"
      ]
    }
  }

  statement {
    sid    = "ManageStagingTerraformState"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::fimatix-devops-starter-tfstate-442847318797/staging/*"
    ]
  }

  statement {
    sid    = "ReadGlobalTerraformState"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::fimatix-devops-starter-tfstate-442847318797/global/terraform.tfstate"
    ]
  }

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

resource "aws_iam_policy" "staging_backend_permissions" {
  name        = "TerraformDeployStagingBackendAccess"
  description = "Allows the staging Terraform deployment role to access staging remote state, global state, and the state lock."

  policy = data.aws_iam_policy_document.staging_backend_permissions.json
}

resource "aws_iam_role_policy_attachment" "staging_backend_permissions" {
  role       = aws_iam_role.staging.name
  policy_arn = aws_iam_policy.staging_backend_permissions.arn
}

# -----------------------------------------------------------------------------
# Production Terraform Backend Permissions
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "prod_backend_permissions" {
  statement {
    sid    = "ListTerraformStateBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::fimatix-devops-starter-tfstate-442847318797"
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "prod/*",
        "global/terraform.tfstate"
      ]
    }
  }

  statement {
    sid    = "ManageProdTerraformState"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::fimatix-devops-starter-tfstate-442847318797/prod/*"
    ]
  }

  statement {
    sid    = "ReadGlobalTerraformState"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::fimatix-devops-starter-tfstate-442847318797/global/terraform.tfstate"
    ]
  }

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

resource "aws_iam_policy" "prod_backend_permissions" {
  name        = "TerraformDeployProdBackendAccess"
  description = "Allows the production Terraform deployment role to access production remote state, global state, and the state lock."

  policy = data.aws_iam_policy_document.prod_backend_permissions.json
}

resource "aws_iam_role_policy_attachment" "prod_backend_permissions" {
  role       = aws_iam_role.prod.name
  policy_arn = aws_iam_policy.prod_backend_permissions.arn
}
