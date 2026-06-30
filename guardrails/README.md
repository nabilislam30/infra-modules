Guardrails Without SCPs

## Objective

Implement account-level guardrails in a single AWS account without using AWS Organizations Service Control Policies.

Because SCPs require AWS Organizations, this phase uses IAM, permission boundaries, AWS Config, and tagging controls to enforce safe operating boundaries.

## Scope

This phase will implement:

- Permission boundaries
- Region restrictions
- Protection for security services
- IAM user creation restrictions
- Read-only human access model
- Environment separation using tags
- AWS Config rules for drift detection

## Guardrail Requirements

### 1. Region Restrictions

Deny resource creation outside approved regions:

- eu-west-2
- eu-west-1

### 2. Security Service Protection

Prevent disabling or deleting:

- CloudTrail
- AWS Config
- GuardDuty
- Security Hub

### 3. IAM User Creation Restriction

Prevent day-to-day users from creating IAM users.

### 4. Read-only Human Access

Human users should have read-only access by default.

Mutating permissions should be reserved for:

- Terraform deployment identity
- Break-glass administrator access

### 5. Environment Tag Separation

Resources should use an environment tag:

```hcl
Environment = "dev"
Environment = "staging"
Environment = "prod"
Environment = "global"
