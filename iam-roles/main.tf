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

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}

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
