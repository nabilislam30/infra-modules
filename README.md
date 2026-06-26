# 🧩 infra-modules

> Reusable Terraform modules for building secure, scalable and immutable AWS infrastructure.

`infra-modules` contains reusable Terraform modules that implement infrastructure components following AWS and Infrastructure as Code (IaC) best practices. These modules are designed to be consumed by the companion **infra-live** repository, which provides the environment-specific deployment configuration.

---

# 📖 Overview

This repository provides reusable building blocks for AWS infrastructure.

Each module is:

* Self-contained
* Versioned using Git tags
* Environment agnostic
* Reusable across multiple AWS accounts and environments
* Designed following Terraform module best practices

Rather than deploying infrastructure directly, this repository exposes reusable modules that are consumed by live environments.

---

# 🏗 Repository Structure

```text
infra-modules/
│
├── security-baseline/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   └── README.md
│
├── vpc/
│
├── compute-asg/
│
├── iam-roles/
│
├── monitoring/
│
├── rds/
│
├── dev/
├── global/
├── prod/
├── staging/
│
├── .gitignore
├── .pre-commit-config.yaml
└── README.md
```

---

# 🎯 Repository Goals

The objective of this repository is to create reusable Terraform modules that can be consumed by any environment without modification.

Each module should:

* Follow Infrastructure as Code principles
* Be reusable across environments
* Minimise duplicated code
* Support version pinning
* Be independently testable
* Follow AWS security best practices

---

# 🧩 Current Modules

| Module            | Purpose                        | Status         |
| ----------------- | ------------------------------ | -------------- |
| Security Baseline | Account-wide security services | ✅ Complete     |
| VPC               | Networking                     | 🚧 In Progress |
| Compute ASG       | EC2 Auto Scaling               | 📅 Planned     |
| IAM Roles         | Reusable IAM components        | 📅 Planned     |
| Monitoring        | CloudWatch & observability     | 📅 Planned     |
| RDS               | Relational databases           | 📅 Planned     |

---

# 🔐 Security Baseline Module

The **security-baseline** module provisions account-wide AWS security services.

Current capabilities include:

* ✅ AWS CloudTrail
* ✅ AWS Config
* ✅ AWS Config Managed Rules
* ✅ Amazon GuardDuty
* ✅ AWS Security Hub
* ✅ IAM Access Analyzer
* ✅ Customer Managed KMS Key
* ✅ CloudWatch Log Group
* ✅ CloudTrail Log Bucket
* ✅ AWS Config Delivery Bucket
* ✅ S3 Public Access Block
* ✅ Default EBS Encryption

---

# 🏛 Module Architecture

```text
Developer

        │

        ▼

infra-live

        │

        ▼

Version-Pinned Module

        │

        ▼

infra-modules

        │

        ▼

Terraform

        │

        ▼

AWS
```

This separation allows infrastructure code to evolve independently from environment configuration.

---

# 📦 Module Versioning

Modules are versioned using Git tags.

Example:

```text
v0.2.0
v0.3.0
v0.4.0
v0.5.0
v0.6.0
v0.8.0
v0.9.0
```

Modules should always be referenced using a specific release tag rather than the `main` branch.

Example usage:

```hcl
module "security_baseline" {
  source = "git::https://github.com/nabilislam30/infra-modules.git//security-baseline?ref=v0.9.0"
}
```

This guarantees repeatable deployments and prevents untested changes from affecting live infrastructure.

---

# 🚀 Development Workflow

Typical workflow when creating or updating a module:

```text
Create Module

        │

        ▼

Develop Feature

        │

        ▼

terraform fmt

        │

        ▼

terraform validate

        │

        ▼

TFLint

        │

        ▼

Trivy

        │

        ▼

Git Commit

        │

        ▼

Git Tag

        │

        ▼

Push Release

        │

        ▼

Consume in infra-live
```

---

# 🧪 Validation

Every module should pass the following validation checks before release:

* Terraform Format (`terraform fmt`)
* Terraform Validate (`terraform validate`)
* TFLint
* Trivy
* Terraform Docs
* Git Pre-Commit Hooks

These checks help ensure consistency, security and maintainability.

---

# 🔒 Design Principles

Each module is designed around the following principles:

* Reusability
* Idempotency
* Least Privilege
* Immutable Infrastructure
* Versioned Releases
* Secure Defaults
* Environment Agnostic
* Simple Module Interfaces

---

# 📂 Consumed By

This repository is consumed by:

```text
infra-live
```

The **infra-live** repository provides the deployment configuration and references these modules using Git version tags.

---

# 📈 Roadmap

Completed

* ✅ Security Baseline Module

In Progress

* 🚧 VPC Module

Planned

* 🔲 Compute Module
* 🔲 Auto Scaling Module
* 🔲 IAM Roles Module
* 🔲 Monitoring Module
* 🔲 RDS Module
* 🔲 CI/CD Support Modules
* 🔲 Shared Networking Components

---

# 🤝 Contributing

1. Create a feature branch.
2. Develop the module.
3. Validate the module.
4. Update documentation.
5. Tag a release.
6. Submit a Pull Request.
7. Merge after approval.

---

# 📜 License

This repository is provided for learning, portfolio, and infrastructure engineering purposes.
