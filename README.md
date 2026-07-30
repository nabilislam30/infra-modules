# ☁️ Immutable AWS Infrastructure with Terraform

<div align="center">

Production-inspired Terraform modules for building secure, scalable and reusable AWS infrastructure.

![Terraform](https://img.shields.io/badge/Terraform-1.8+-623CE4?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-eu--west--2-FF9900?logo=amazonaws&logoColor=white)
![IaC](https://img.shields.io/badge/Infrastructure-Terraform-blue)
![Status](https://img.shields.io/badge/Status-Active-success)
![License](https://img.shields.io/badge/License-MIT-green)

</div>

---

# 📖 Overview

This repository contains reusable Terraform modules for deploying AWS infrastructure using Infrastructure as Code (IaC).

Rather than creating infrastructure independently for every project, common AWS resources are packaged into reusable modules that can be versioned, tested and consumed by multiple environments.

The project follows modern DevOps engineering practices including:

- Modular Terraform design
- Infrastructure as Code
- Version-controlled releases
- Security by default
- Reusable infrastructure
- Consistent deployments
- Separation of environments

This repository is intended to be used alongside the **infra-live** repository, which consumes these versioned modules to deploy infrastructure into AWS.

---

# 🎯 Project Objectives

The goal of this project is to demonstrate production-inspired Infrastructure as Code practices through reusable Terraform modules.

Key objectives include:

- Build reusable Terraform modules.
- Standardise AWS infrastructure deployments.
- Reduce manual provisioning.
- Improve security through reusable guardrails.
- Promote modular infrastructure design.
- Version infrastructure using Git tags and GitHub Releases.
- Reduce configuration drift.
- Improve maintainability across environments.

---

# ✨ Features

## Security

- AWS CloudTrail
- AWS Config
- GuardDuty
- Security Hub
- IAM Access Analyzer
- CloudWatch Logging
- KMS Encryption
- Secure S3 Storage

## Governance

- IAM Guardrails
- Permission Boundaries
- Region Restrictions
- Least Privilege
- Developers ReadOnly Role

## Infrastructure

- Modular Terraform
- Environment Agnostic Modules
- Version Controlled Releases
- GitHub Release Tags
- Reusable Components

---

# 📊 Project Status

| Module | Status |
|---------|--------|
| Security Baseline | ✅ Complete |
| Guardrails | ✅ Complete |
| VPC | 🚧 In Progress |
| Compute ASG | 🚧 Planned |
| IAM Roles | 🚧 Planned |
| Monitoring | 🚧 Planned |
| Amazon RDS | 🚧 Planned |
| AMI Pipeline | 🚧 Planned |

Latest Release: **v1.2.6**

Release history is available in **[CHANGELOG.md](CHANGELOG.md)**.

---

# 🏗️ High-Level Architecture

```
GitHub Releases
        │
        ▼
+--------------------+
|    infra-live      |
| Environment Config |
+--------------------+
          │
          ▼
Terraform Modules
          │
          ▼
+--------------------+
|   infra-modules    |
+--------------------+
          │
          ▼
 AWS Infrastructure
```

The reusable modules in this repository are consumed by the `infra-live` repository to deploy infrastructure into AWS environments.

---

# 📂 Repository Structure

```
infra-modules/
│
├── security-baseline/
├── guardrails/
├── vpc/
├── compute-asg/
├── iam-roles/
├── monitoring/
├── rds/
├── ami-pipeline/
│
├── global/
├── staging/
├── prod/
│
├── ARCHITECTURE.md
├── SECURITY.md
├── CHANGELOG.md
└── README.md
```

---

# 📦 Available Modules

| Module | Description |
|---------|-------------|
| Security Baseline | Deploys foundational AWS security services. |
| Guardrails | Implements preventative IAM controls and governance. |
| VPC | Creates reusable networking infrastructure. |
| Compute ASG | Deploys scalable EC2 Auto Scaling Groups. |
| IAM Roles | Creates reusable IAM roles and policies. |
| Monitoring | Deploys CloudWatch monitoring resources. |
| RDS | Creates managed relational databases. |
| AMI Pipeline | Builds immutable Amazon Machine Images. |

Each module contains its own documentation with configuration examples, inputs, outputs and implementation details.

---

# 🚀 Getting Started

This section explains how to get started with the repository, install the required tools and consume the Terraform modules in your own infrastructure projects.

---

# Prerequisites

Before using this repository, ensure the following tools are installed.

| Tool | Version | Purpose |
|------|---------|---------|
| Terraform | 1.8+ | Infrastructure as Code |
| AWS CLI | Latest | AWS Authentication |
| Git | Latest | Source Control |
| GitHub | Account | Module Source |
| AWS Account | Active | Infrastructure Deployment |

Verify your installation:

```bash
terraform version
aws --version
git --version
```

---

# Clone the Repository

Clone the repository locally.

```bash
git clone https://github.com/nabilislam30/infra-modules.git

cd infra-modules
```

---

# Repository Layout

Each module follows a consistent Terraform structure.

```
module-name/

├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
└── versions.tf
```

| File | Purpose |
|------|---------|
| main.tf | Defines AWS resources |
| variables.tf | Module input variables |
| outputs.tf | Values exported to other modules |
| versions.tf | Terraform and provider versions |
| README.md | Module documentation |

This structure is consistent across every module to improve maintainability and developer experience.

---

# Using a Module

Modules are intended to be consumed by the **infra-live** repository.

Example:

```hcl
module "security_baseline" {

  source = "git::https://github.com/nabilislam30/infra-modules.git//security-baseline?ref=v1.2.6"

}
```

Pinning the module to a release ensures deployments remain stable and reproducible.

---

# Terraform Workflow

The recommended deployment workflow is shown below.

```
Clone Repository
        │
        ▼
terraform init
        │
        ▼
terraform fmt
        │
        ▼
terraform validate
        │
        ▼
terraform plan
        │
        ▼
terraform apply
```

Each stage validates the infrastructure before any changes are applied to AWS.

---

# Common Terraform Commands

Initialise Terraform.

```bash
terraform init
```

Format Terraform files.

```bash
terraform fmt -recursive
```

Validate configuration.

```bash
terraform validate
```

Preview infrastructure changes.

```bash
terraform plan
```

Deploy infrastructure.

```bash
terraform apply
```

Destroy infrastructure.

```bash
terraform destroy
```

---

# Versioning

This repository follows **Semantic Versioning (SemVer)**.

```
MAJOR.MINOR.PATCH
```

Example releases:

```
v1.0.0
v1.1.0
v1.2.0
v1.2.6
```

Versioning allows consumers of the modules to safely upgrade infrastructure while controlling when changes are introduced.

---

# Release Management

Every release is published using:

- Git Tags
- GitHub Releases
- Semantic Versioning

Infrastructure should always reference a tagged release rather than the `main` branch.

Example:

```hcl
source = "git::https://github.com/nabilislam30/infra-modules.git//guardrails?ref=v1.2.6"
```

A complete history of changes is maintained in **[CHANGELOG.md](CHANGELOG.md)**.

---

# Security Highlights

Security is a core design principle throughout this repository.

Current security capabilities include:

- AWS CloudTrail
- AWS Config
- AWS GuardDuty
- AWS Security Hub
- IAM Access Analyzer
- Customer Managed KMS Keys
- CloudWatch Log Groups
- Secure S3 Configuration
- IAM Permission Boundaries
- Region Restrictions
- Least Privilege IAM Policies

Additional implementation details are available in **[SECURITY.md](SECURITY.md)**.

---

# Documentation

Further documentation is available throughout the repository.

| Document | Description |
|----------|-------------|
| README.md | Project overview and getting started |
| ARCHITECTURE.md | Repository architecture and design decisions |
| SECURITY.md | Security controls and governance |
| CHANGELOG.md | Complete release history |
| security-baseline/README.md | Security Baseline module |
| guardrails/README.md | Guardrails module |
| vpc/README.md | VPC module |
| monitoring/README.md | Monitoring module |
| iam-roles/README.md | IAM Roles module |
| compute-asg/README.md | Compute ASG module |
| rds/README.md | Amazon RDS module |
| ami-pipeline/README.md | AMI Pipeline module |

---

# Best Practices

When consuming modules from this repository:

- Pin modules to a released version.
- Avoid referencing the `main` branch.
- Review release notes before upgrading.
- Validate infrastructure before deployment.
- Use environment-specific variables.
- Keep Terraform providers up to date.
- Follow the principle of least privilege.
- Review Terraform plans before applying changes.

# 🗺️ Roadmap

The project is being developed incrementally, with each module designed, tested and versioned independently before release.

## ✅ Completed

- Security Baseline Module
- Guardrails Module
- CloudTrail Integration
- AWS Config
- GuardDuty
- Security Hub
- IAM Access Analyzer
- CloudWatch Logging
- KMS Encryption
- Permission Boundaries
- Region Restrictions
- Developers ReadOnly Role
- GitHub Release Management
- Semantic Versioning
- Modular Repository Structure

---

## 🚧 In Progress

- VPC Module
- Networking Components
- Route Tables
- Security Groups
- Subnets

---

## 📋 Planned

Future enhancements include:

### Infrastructure

- Compute Auto Scaling Groups
- Amazon RDS
- Application Load Balancers
- ECS Support
- Lambda Modules

### Networking

- NAT Gateways
- Transit Gateway
- VPC Endpoints
- Flow Logs
- IPv6 Support

### Security

- AWS WAF
- AWS Shield
- Secrets Manager
- IAM Identity Center Integration
- Cross Account IAM Roles

### Monitoring

- CloudWatch Dashboards
- CloudWatch Alarms
- SNS Notifications
- Microsoft Teams Integration
- Grafana Dashboards
- EventBridge Alerts

### CI/CD

- GitHub Actions
- Azure DevOps Pipelines
- Automated Testing
- Terraform Linting
- Security Scanning
- Release Automation

---

# 🤝 Contributing

Contributions are welcome and encouraged.

If you wish to improve the project:

1. Fork the repository.
2. Create a feature branch.
3. Make your changes.
4. Test your Terraform configuration.
5. Submit a Pull Request.

Please ensure all Terraform code:

- Passes `terraform fmt`
- Passes `terraform validate`
- Uses consistent formatting
- Includes documentation updates where appropriate
- Follows the existing module structure

---

# 📏 Repository Standards

To maintain consistency across the project, every module should:

- Follow the standard Terraform file layout.
- Be self-contained and reusable.
- Expose configurable variables.
- Export meaningful outputs.
- Include comprehensive documentation.
- Follow semantic versioning.
- Avoid hard-coded environment values.
- Adhere to Infrastructure as Code best practices.

---

# 📚 Additional Documentation

The root README provides an overview of the project.

Detailed documentation is available within the repository.

| Document | Purpose |
|----------|---------|
| **ARCHITECTURE.md** | Overall repository architecture, design principles and infrastructure layout. |
| **SECURITY.md** | Security controls, governance and compliance implementation. |
| **CHANGELOG.md** | Complete release history and version changes. |
| **security-baseline/README.md** | Detailed Security Baseline module documentation. |
| **guardrails/README.md** | Guardrails implementation and IAM governance. |
| **vpc/README.md** | Networking module documentation. |
| **compute-asg/README.md** | Auto Scaling infrastructure module. |
| **iam-roles/README.md** | IAM roles and policy module. |
| **monitoring/README.md** | Monitoring and observability module. |
| **rds/README.md** | Amazon RDS deployment module. |
| **ami-pipeline/README.md** | Immutable AMI pipeline documentation. |

Each module README includes:

- Overview
- Architecture
- Resources Created
- Input Variables
- Outputs
- Example Usage
- Future Enhancements

---

# 📝 Release Strategy

This repository follows a structured release process to ensure stability and repeatability.

Every release is:

- Tagged using Semantic Versioning.
- Published as a GitHub Release.
- Referenced by downstream infrastructure repositories.
- Documented in `CHANGELOG.md`.

Example release lifecycle:

```
Development
      │
      ▼
Feature Complete
      │
      ▼
Testing
      │
      ▼
Git Tag
      │
      ▼
GitHub Release
      │
      ▼
Consumed by infra-live
```

This approach ensures that infrastructure deployments always reference tested and versioned modules.

---

# 📄 License

This project is licensed under the **MIT License**.

See the [LICENSE](LICENSE) file for full details.

---

# 👨‍💻 Author

**Nabil Islam**

Cloud & DevOps Engineer with a focus on Infrastructure as Code, AWS and automation.

GitHub: https://github.com/nabilislam30

---

# ⭐ Acknowledgements

This repository has been developed as part of an ongoing effort to strengthen cloud engineering and DevOps capabilities through hands-on implementation of production-inspired AWS infrastructure.

The project demonstrates practical experience with:

- Terraform
- Amazon Web Services (AWS)
- Infrastructure as Code (IaC)
- Cloud Security
- IAM Governance
- Modular Infrastructure Design
- Version-Controlled Infrastructure
- DevOps Best Practices

---

<div align="center">

### Thank you for visiting this repository!

If you found this project useful or interesting, consider giving it a ⭐ on GitHub.

</div>
